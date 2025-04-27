import Foundation

@MainActor
class PostDetailViewModel: ObservableObject {
    @Published var similarPosts: [Post] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let postId: String
    
    init(postId: String) {
        self.postId = postId
    }
    
    func fetchSimilarPosts() async {
        isLoading = true
        error = nil
        
        do {
            var components = URLComponents(string: "\(APIConstants.baseURL)\(APIConstants.similarPosts)")!
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