import SwiftUI

struct PostsView: View {
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading && viewModel.posts.isEmpty {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("retry".localized) {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else if viewModel.posts.isEmpty {
                    VStack {
                        Text("no_posts".localized)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List(viewModel.posts) { post in
                        NavigationLink(destination: PostDetailView(post: post)) {
                            PostRowView(post: post)
                        }
                        .task {
                            await viewModel.loadMoreIfNeeded(currentPost: post)
                        }
                    }
                        .listStyle(InsetGroupedListStyle())

                    .refreshable {
                        await viewModel.refresh()
                    }
                    .overlay(Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                        }
                    })
                }
            }
            .navigationTitle("latest_posts".localized)
        }
        .task {
            await viewModel.fetchPosts()
        }
    }
}

struct PostRowView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
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
                
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        Text(post.user.username)
                            .font(.headline)
                        
                        if post.user.verified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
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
            
            Text(post.title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(post.body)
                .font(.body)
                .lineLimit(3)
            
            if !post.mediaUrls.isEmpty {
                MediaSliderView(mediaUrls: post.mediaUrls, height: 200)
            }
            
            HStack(spacing: 16) {
                if (post.views ?? 0) > 0 {
                    Label("\(post.views ?? 0)", systemImage: "eye")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if (post.comments ?? 0) > 0 {
                    Label("\(post.comments ?? 0)", systemImage: "message")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    PostsView()
} 