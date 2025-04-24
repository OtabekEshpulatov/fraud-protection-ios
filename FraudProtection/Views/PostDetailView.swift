import SwiftUI
import AVKit

struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel: PostDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(post: Post) {
        self.post = post
        _viewModel = StateObject(wrappedValue: PostDetailViewModel(postId: post.id))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        // User profile section
                        HStack(spacing: 8) {
                            if let profilePhotoUrl = post.user.profilePhotoUrl {
                                AsyncImage(url: URL(string: profilePhotoUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(post.user.username)
                                        .font(.headline)
                                    
                                    if post.user.verified == true {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.blue)
                                            .font(.caption)
                                    }
                                }
                                
                                if let region = post.region {
                                    Text(region)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Dismiss button
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .background(Color(UIColor.systemBackground))
                
                // Post content
                VStack(alignment: .leading, spacing: 16) {
                    // Media content
                    if !post.mediaUrls.isEmpty {
                        MediaSliderView(mediaUrls: post.mediaUrls, height: 300)
                    }
                    
                    // Post title and content
                    VStack(alignment: .leading, spacing: 12) {
                        Text(post.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(post.body)
                            .font(.body)
                        
                        // Date
                        Text(post.formattedDate)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Similar posts section
                    if !viewModel.similarPosts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("similar_posts".localized)
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(viewModel.similarPosts) { similarPost in
                                        NavigationLink(destination: PostDetailView(post: similarPost)) {
                                            SimilarPostCard(post: similarPost)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.fetchSimilarPosts()
        }
    }
}

struct SimilarPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            if !post.mediaUrls.isEmpty {
                MediaSliderView(mediaUrls: post.mediaUrls, height: 120)
            }
            
            Text(post.title)
                .font(.headline)
                .lineLimit(2)
        }
        .frame(width: 200)
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: Post(
            id: "1",
            title: "Sample Post",
            body: "This is a sample post content that spans multiple lines to demonstrate how the text wraps and how the layout handles longer content.",
            mediaUrls: ["https://example.com/image.jpg"],
            user: PostUser(
                id: UUID(),
                username: "John Doe",
                verified: true,
                profilePhotoUrl: nil
            ),
            region: "New York",
            createdDate: Date().timeIntervalSince1970,
            views: 42,
            comments: 5
        ))
    }
} 
