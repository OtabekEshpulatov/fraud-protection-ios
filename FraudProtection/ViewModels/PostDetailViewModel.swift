import Foundation

@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var similarPosts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var post: Post?
    
    private let postId: String
    var skipInitialFetch: Bool = false
    
    init(postId: String) {
        print("📱 PostDetailViewModel init with postId:", postId)
        self.postId = postId
    }
    
    func fetchPost() async {
        print("📱 fetchPost called, skipInitialFetch:", skipInitialFetch)
        print("📱 Current post:", post as Any)
        
        // Skip fetch if we already have the post data
        if post != nil && skipInitialFetch {
            print("📱 Skipping fetch as we already have post data")
            return
        }
        
        isLoading = true
        error = nil
        
        do {
            let url = URL(string: "\(EnvManager.shared.require("API_URL"))\(APIConstants.singlePost)/\(postId)")!
            print("📱 Fetching post from URL:", url)
            let (data, response) = try await URLSession.shared.data(from: url)
            print("📱 Received response:", response)
            let fetchedPost = try JSONDecoder().decode(Post.self, from: data)
            print("📱 Successfully decoded post:", fetchedPost)
            post = fetchedPost
        } catch {
            self.error = error.localizedDescription
            print("❌ Error fetching post:", error)
        }
        
        isLoading = false
    }
    
    func fetchSimilarPosts() async {
        isLoading = true
        error = nil
        
        do {
            var components = URLComponents(string: "\(EnvManager.shared.require("API_URL"))\(APIConstants.similarPosts)")!
            components.queryItems = [
                URLQueryItem(name: "postId", value: postId),
                URLQueryItem(name: "limit", value: "5")
            ]
            
            let url = components.url!
            let (data, _) = try await URLSession.shared.data(from: url)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            
            similarPosts = posts
        } catch {
            self.error = error.localizedDescription
            print("Error fetching similar posts: \(error)")
        }
        
        isLoading = false
    }
} 
