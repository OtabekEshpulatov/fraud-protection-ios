import SwiftUI
import AVKit

struct PostDetailView: View {
    let post: Post
    @StateObject private var viewModel: PostDetailViewModel
    
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
                                
                                HStack(spacing: 8) {
                                    if let region = post.region {
                                        Text(region)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Text(post.formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom)
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
                    }
                    .padding(.horizontal)
                    
                    // Tags section
                    if !post.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(post.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Divider before similar posts
                    Divider()
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Similar posts section
                    if !viewModel.similarPosts.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("similar_posts".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                            
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
        .task {
            await viewModel.fetchSimilarPosts()
        }
    }
}

struct SimilarPostCard: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !post.mediaUrls.isEmpty {
                MediaSliderView(mediaUrls: post.mediaUrls, height: 120)
            }
            
            Text(post.title)
                .font(.subheadline)
                .lineLimit(3)

                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            HStack {
                if let region = post.region {
                    Text(region)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(post.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 200, height: 200, alignment: .bottom)
        .padding()
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
            comments: 5,
            tags: ["Test", "SwiftUI", "Preview"]
        ))
    }
} 
