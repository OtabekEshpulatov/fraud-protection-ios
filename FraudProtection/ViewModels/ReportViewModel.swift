import Foundation
import SwiftUI

class ReportViewModel: ObservableObject {
    
    @ObservedObject var authViewModel: AuthViewModel

    
    
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var selectedRegion: RegionDto?
    @Published var mediaFiles: [MediaFile] = []
    @Published var mediaIds: [String] = []
    @Published var regions: [RegionDto] = []
    @Published var isSubmitting: Bool = false

    @Published var apiResponseMessage: String? = nil


    private let session = URLSession.shared
    private let baseURL = EnvManager.shared.get("API_URL")!
    
    init(authViewModel: AuthViewModel) {
           self.authViewModel = authViewModel
       }

    func fetchRegions() {
        guard let url = URL(string: (baseURL + "/api/v1/regions")) else { return }
        session.dataTask(with: url) { data, _, _ in
            print(url, data)
            guard let data = data,
                  let decoded = try? JSONDecoder().decode([RegionDto].self, from: data) else { return }
            DispatchQueue.main.async {
                self.regions = decoded
            }
        }.resume()
    }

    func uploadMedia(_ mediaFile: MediaFile, completion: @escaping (String?) -> Void) {
        guard let fileData = try? Data(contentsOf: mediaFile.url),
              let url = URL(string: baseURL + "/file") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let filename = mediaFile.url.lastPathComponent

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        session.uploadTask(with: request, from: body) { data, response, error in
            guard let data = data,
                  let result = try? JSONDecoder().decode(MediaUploadResponse.self, from: data) else {
                completion(nil)
                return
            }
            DispatchQueue.main.async {
                completion(result.fileId)
            }
        }.resume()
    }

    func submitReport(completion: @escaping (Bool) -> Void) {
        
        if authViewModel.isAuthenticationNonExpired() == false {
            completion(false)
            return
        }
        
        print("Submitting report")
        guard let regionId = selectedRegion?.id,
              let url = URL(string: baseURL + "/api/v1/report") else {
            completion(false)
            return
        }

        isSubmitting = true
        let dispatchGroup = DispatchGroup()
        mediaIds = []

        for file in mediaFiles {
            dispatchGroup.enter()
            uploadMedia(file) { [weak self] fileId in
                if let fileId = fileId {
                    self?.mediaIds.append(fileId)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            let payload = PostRequestDto(title: self.title, body: self.body, mediaIds: self.mediaIds, regionId: regionId)
            guard let data = try? JSONEncoder().encode(payload) else {
                completion(false)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            if let tokenType = self.authViewModel.authToken?.token_type,
               let accessToken = self.authViewModel.authToken?.access_token {
                let authValue = "\(tokenType) \(accessToken)"
                request.setValue(authValue, forHTTPHeaderField: "Authorization")
            }

        
            self.session.dataTask(with: request) { data, response, _ in
                DispatchQueue.main.async {
                    print(data,response)
                    self.isSubmitting = false
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        self.apiResponseMessage = responseString
                    } else {
                        self.apiResponseMessage = "No response data"
                    }
                    completion((response as? HTTPURLResponse)?.statusCode == 200)
                }
            }.resume()
        }
    }

    func getLocalizedRegionName(for region: RegionDto) -> String {
        let currentLocale = LanguageManager.shared.currentLanguage.rawValue
        return region.names.first(where: { $0.locale == currentLocale })?.name ?? region.names.first?.name ?? "Unknown"
    }

    func getSelectedRegionName() -> String? {
        guard let selectedRegion = selectedRegion else { return nil }
        return getLocalizedRegionName(for: selectedRegion)
    }
}
