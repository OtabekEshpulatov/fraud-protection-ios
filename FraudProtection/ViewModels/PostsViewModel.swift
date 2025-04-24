import Foundation

@MainActor
class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var currentPage = 0
    private var hasMorePages = true
    private let networkMonitor = NetworkMonitor.shared
    
    init() {
        Task {
            await loadCachedPosts()
        }
    }
    
    private func loadCachedPosts() async {
        posts = await StorageManager.shared.getCachedPosts()
    }
    
    func refresh() async {
        currentPage = 0
        hasMorePages = true
        
        if networkMonitor.isConnected {
            await fetchPosts()
        } else {
            await loadCachedPosts()
        }
    }
    
    func loadMoreIfNeeded(currentPost post: Post) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }),
              index == posts.count - 1,
              hasMorePages,
              !isLoading else {
            return
        }
        
        currentPage += 1
        await fetchPosts()
    }
    
    func fetchPosts() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            var components = URLComponents(string: "http://localhost:8080/api/v1/posts/latest")!
            components.queryItems = [
                URLQueryItem(name: "page", value: String(currentPage)),
                URLQueryItem(name: "size", value: "10")
            ]
            
            let url = components.url!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode([Post].self, from: data)
            
            // Remove duplicates based on post ID
            let newPosts = response.filter { newPost in
                !posts.contains { $0.id == newPost.id }
            }
            
            if currentPage == 0 {
                posts = response
            } else {
                posts.append(contentsOf: newPosts)
            }
            
            hasMorePages = !response.isEmpty
            
            // Cache the posts
            await StorageManager.shared.cachePosts(posts)
            
        } catch {
            self.error = error.localizedDescription
            print("Error fetching posts: \(error)")
            
            // If offline, load cached posts
            if !networkMonitor.isConnected {
                await loadCachedPosts()
            }
        }
        
        isLoading = false
    }
} 
