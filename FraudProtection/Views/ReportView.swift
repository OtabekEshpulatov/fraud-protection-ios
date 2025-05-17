import SwiftUI
import PhotosUI
import Photos


struct ReportView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showDocumentPicker = false
    
    @StateObject private var viewModel: ReportViewModel
    
    @State private var currentTab = 0
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isSubmissionSuccess = false
    
    init() {
          _viewModel = StateObject(wrappedValue: ReportViewModel(authViewModel: AuthViewModel()))
      }
  
    
    
    
    var body: some View {
        if authViewModel.isAuthenticationNonExpired(){
            mainView
                .toolbar(.hidden)
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    var mainView: some View {
        if isSubmissionSuccess {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.green)
                Text("report_success_message".localized)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }else{
            
            VStack(spacing: 0) {
                // Step indicator at the top
                HStack {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(index == currentTab ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Optional: textual step indicator
                Text("Step \(currentTab + 1) of 4")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                TabView(selection: $currentTab) {
                    // Step 1: Title & Body
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Title", text: $viewModel.title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        ZStack(alignment: .topLeading){
                            TextEditor(text: $viewModel.body)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.secondary, lineWidth: 0.2)
                                )
                                .padding()
                            
                            if(viewModel.body.isEmpty){
                                Text("Enter your message...")
                                    .foregroundColor(Color.secondary.opacity(0.5))
                                    .padding(24)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Next") {
                            currentTab = 1
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .tag(0)
                    
                    // Step 2: Region Selection
                    VStack(spacing: 16) {
                        if viewModel.regions.isEmpty {
                            ProgressView("Loading regions...")
                                .frame(maxHeight: .infinity)
                        } else {
                            VStack(spacing: 0){
                                Picker("Select Region", selection: Binding(
                                    get: { viewModel.selectedRegion },
                                    set: { viewModel.selectedRegion = $0 }
                                )) {
                                    ForEach(viewModel.regions) { region in
                                        Text(viewModel.getLocalizedRegionName(for: region))
                                            .tag(region as RegionDto?)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .padding()
                                Spacer()
                            }.onAppear{
                                viewModel.selectedRegion = viewModel.regions.first
                            }
                            
                            Spacer()
                            
                            HStack {
                                Button("Back") {
                                    currentTab = 0
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                                .padding()
                                
                                Button("Next") {
                                    currentTab = 2
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                        }
                    }.onAppear{
                        viewModel.fetchRegions()
                    }
                    .tag(1)
                    
                    // Step 3: Media Upload
                    VStack(spacing: 16) {
                        if !viewModel.mediaFiles.isEmpty {
                            let fixedColumn = [
                                GridItem(.flexible(minimum: 10)),
                                GridItem(.flexible(minimum: 10)),
                                GridItem(.flexible(minimum: 10))
                            ]
                            ScrollView {
                                LazyVGrid(columns: fixedColumn, spacing: 8) {
                                    ForEach(viewModel.mediaFiles, id: \.id) { media in
                                        VStack {
                                            if media.url.pathExtension.lowercased() == "jpg" || 
                                               media.url.pathExtension.lowercased() == "png" || 
                                               media.url.pathExtension.lowercased() == "jpeg" {
                                                Image(uiImage: UIImage(contentsOfFile: media.url.path) ?? UIImage())
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .clipped()
                                            } else if media.url.pathExtension.lowercased() == "mp4" {
                                                VideoPlayerView(url: media.url)
                                                    .frame(width: 80, height: 80)
                                            }
                                            
                                            Button(action: {
                                                if let index = viewModel.mediaFiles.firstIndex(where: { $0.url == media.url }) {
                                                    viewModel.mediaFiles.remove(at: index)
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        
                        Spacer()
                        
                        PhotosPicker(selection: $photoPickerItems,
                                    maxSelectionCount: 10,
                                    matching: .any(of: [.images, .videos])) {
                            Label("select_media".localized, systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .onChange(of: photoPickerItems) { newItems in
                            Task {
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self),
                                       let url = saveMediaToTemporaryFile(data: data, item: item) {
                                        viewModel.mediaFiles.append(MediaFile(url: url))
                                    }
                                }
                                // Clear the selection after processing
                                photoPickerItems = []
                            }
                        }
                        
                        Spacer()
                        
                        HStack {
                            Button("Back") {
                                currentTab = 1
                            }
                            .buttonStyle(.bordered)
                            .frame(maxWidth: .infinity)
                            .padding()
                            
                            Button("Next") {
                                currentTab = 3
                            }
                            .buttonStyle(.borderedProminent)
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                    }
                    .tag(2)
                    
                    // Step 4: Confirmation & Preview
                    VStack {
                        Spacer()
                        
                        // Construct a preview Post object
                        let previewPost = Post(
                            id: UUID().uuidString,
                            title: viewModel.title,
                            body: viewModel.body,
                            mediaUrls: viewModel.mediaFiles.map { $0.url.absoluteString },
                            user: PostUser(
                                id: UUID(uuidString: UserPreferencesManager.shared.userId ?? "") ?? UUID(),
                                username: UserPreferencesManager.shared.username ?? "You",
                                verified: true,
                                profilePhotoUrl: nil
                            ),
                            region: viewModel.getSelectedRegionName(),
                            createdDate: Date().timeIntervalSince1970,
                            views: nil,
                            comments: nil,
                            tags: []
                        )
                        
                        PostDetailView(post: previewPost)
                            .disabled(true) // Prevent navigation from preview
                        
                        Spacer()
                        
                        if viewModel.isSubmitting {
                            ProgressView("Submitting...")
                        } else {
                            if let message = viewModel.apiResponseMessage {
                                Text(message)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                            HStack {
                                Button("Back") {
                                    currentTab = 2
                                }
                                .buttonStyle(.bordered)
                                .frame(maxWidth: .infinity)
                                .padding()
                                
                                Button("Submit") {
                                    viewModel.submitReport { success in
                                        isSubmissionSuccess = success
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                        }
                        Spacer()
                    }
                    
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // hide default
                .animation(.easeInOut, value: currentTab)
            }
        }
    }
    
    private func saveMediaToTemporaryFile(data: Data, item: PhotosPickerItem) -> URL? {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        
        // Get the file extension based on the item type
        let fileExtension = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
}

#Preview {
    ReportView()
        .environmentObject(AuthViewModel.shared)
}
