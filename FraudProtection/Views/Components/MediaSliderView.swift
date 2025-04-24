import SwiftUI

struct MediaSliderView: View {
    let mediaUrls: [String?]
    let height: CGFloat
    
    @State private var currentIndex = 0
    @State private var cachedImages: [String: UIImage] = [:]
    
    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $currentIndex) {
                ForEach(mediaUrls.indices, id: \.self) { index in
                    Group {
                        if let url = mediaUrls[index] {
                            if let cachedImage = cachedImages[url] {
                                Image(uiImage: cachedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                AsyncImage(url: URL(string: url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .task {
                                            if let uiImage = await image.asUIImage(),
                                               let imageData = uiImage.jpegData(compressionQuality: 0.8) {
                                                await StorageManager.shared.saveMedia(imageData, for: url)
                                                cachedImages[url] = uiImage
                                            }
                                        }
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                        } else {
                            VStack {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                Text("media_unavailable".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.gray.opacity(0.1))
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if mediaUrls.count > 1 {
                HStack(spacing: 8) {
                    ForEach(mediaUrls.indices, id: \.self) { index in
                        Circle()
                            .fill(currentIndex == index ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
        }
        .task {
            for url in mediaUrls.compactMap({ $0 }) {
                if let cachedData = await StorageManager.shared.getCachedMedia(for: url),
                   let image = UIImage(data: cachedData) {
                    cachedImages[url] = image
                }
            }
        }
    }
}

extension Image {
    func asUIImage() async -> UIImage? {
        let renderer = await ImageRenderer(content: self)
        return await renderer.uiImage
    }
}

#Preview {
    MediaSliderView(
        mediaUrls: [
            "https://example.com/image1.jpg",
            nil,
            "https://example.com/image3.jpg"
        ],
        height: 200
    )
} 
