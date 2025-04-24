import Foundation

actor StorageManager {
    static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    private let postsCacheKey = "cached_posts"
    private var postsCache: [String: Post] = [:]
    private var mediaCache: [String: Data] = [:]
    
    private init() {
        loadCachedPosts()
    }
    
    private func loadCachedPosts() {
        if let data = defaults.data(forKey: postsCacheKey),
           let posts = try? JSONDecoder().decode([Post].self, from: data) {
            posts.forEach { postsCache[$0.id] = $0 }
        }
    }
    
    func cachePosts(_ posts: [Post]) {
        posts.forEach { postsCache[$0.id] = $0 }
        saveCachedPosts()
    }
    
    func getCachedPosts() -> [Post] {
        Array(postsCache.values).sorted { $0.createdDate > $1.createdDate }
    }
    
    private func saveCachedPosts() {
        if let data = try? JSONEncoder().encode(Array(postsCache.values)) {
            defaults.set(data, forKey: postsCacheKey)
        }
    }
    
    func saveMedia(_ data: Data, for url: String) {
        mediaCache[url] = data
    }
    
    func getCachedMedia(for url: String) -> Data? {
        mediaCache[url]
    }
    
    func clearCache() {
        postsCache.removeAll()
        mediaCache.removeAll()
        defaults.removeObject(forKey: postsCacheKey)
    }
} 