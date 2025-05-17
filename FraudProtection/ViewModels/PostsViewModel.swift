import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var currentPage = 0
    private let networkMonitor = NetworkMonitor.shared
    private var currentTask: Task<Void, Never>?
    private var retryCount = 0
    private let maxRetries = 2 // Maximum number of retry attempts
    
    func initPosts() async {
        // Cancel any existing task
        currentTask?.cancel()
        
        currentPage = 0
        posts = []
        if networkMonitor.isConnected {
            await fetchPosts()
        } else {
            await posts = StorageManager.shared.getCachedPosts()
        }
    }
    
    func fetchPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            var requestUrl = EnvManager.shared.require("API_URL") + (APIConstants.posts)
            print(requestUrl)
            var components = URLComponents(string: requestUrl)!
            components.queryItems = [
                URLQueryItem(name: "limit", value: "-1"),
            ]
            
            let url = components.url!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([Post].self, from: data)
            
            // Reset retry count on successful request
            retryCount = 0
            
            // Remove duplicates based on post ID
            let newPosts = response.filter { newPost in
                !posts.contains { $0.id == newPost.id }
            }
            
            if currentPage == 0 {
                posts = newPosts
            } else {
                posts.append(contentsOf: newPosts)
            }
            
            currentPage = currentPage + 1
            
            await StorageManager.shared.clearPostsCache()
            // Cache the posts
            await StorageManager.shared.cachePosts(newPosts)
            
        } catch let error as URLError where error.code == .cancelled {
            // Handle cancelled request with retry logic
            if retryCount < maxRetries {
                retryCount += 1
                print("Request was cancelled, retrying... (Attempt \(retryCount) of \(maxRetries))")
                // Add a small delay before retrying
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                await fetchPosts()
            } else {
                print("Max retry attempts reached")
                self.error = "Failed to load posts after multiple attempts"
            }
        } catch {
            self.error = error.localizedDescription
            print("Error fetching posts: \(error)")
        }
        
        isLoading = false
    }
    
    func refresh() async {
        retryCount = 0 // Reset retry count on manual refresh
        currentPage = 0
        posts = []
        await fetchPosts()
    }
    
    func loadMoreIfNeeded(currentPost: Post) async {
        guard !isLoading else { return }
        
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.id == currentPost.id }) ?? 0 >= thresholdIndex {
            await fetchPosts()
        }
    }
} 
