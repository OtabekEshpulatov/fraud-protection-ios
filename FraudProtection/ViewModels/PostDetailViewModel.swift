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
            let url = URL(string: "\(APIConstants.baseURL)/posts/\(postId)/similar")!
            let request = URLRequest(url: url)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let posts = try JSONDecoder().decode([Post].self, from: data)
            
            similarPosts = posts
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
} 