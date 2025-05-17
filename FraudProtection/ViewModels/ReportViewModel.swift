import Foundation
import Combine

class ReportViewModel: ObservableObject {
    
    @Published var title: String = ""
    @Published var body: String = ""
    @Published var regionId: String = "" // Example for selecting region
    @Published var fileUrl: URL? = nil
    @Published var mediaIds: [String] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    // Function to upload media
    func uploadMedia(fileURL: URL, completion: @escaping (String?, String?, Error?) -> Void) {
        FileUploadManager.uploadMedia(fileURL: fileURL) { fileId, fileUrl, error in
            completion(fileId, fileUrl, error)
        }
    }
    
    // Function to report the incident
    func reportIncident() {
        guard !title.isEmpty, !body.isEmpty, !regionId.isEmpty else {
            self.errorMessage = "All fields are required!"
            return
        }

        self.isLoading = true
        self.errorMessage = nil

        // Upload the media if there's a file URL
        if let fileUrl = fileUrl {
            uploadMedia(fileURL: fileUrl) { [weak self] fileId, fileUrl, error in
                guard let self = self else { return }
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Failed to upload file: \(error.localizedDescription)"
                    return
                }

                if let fileId = fileId {
                    self.mediaIds.append(fileId) // Add the fileId to the mediaIds
                }
                self.submitReport() // Call report submission after file upload (if any)
            }
        } else {
            submitReport() // If no file to upload, just submit the report
        }
    }
    
    private func submitReport() {
        let apiBase = EnvManager.shared.require("API_URL")
        guard let url = URL(string: "\(apiBase)/api/v1/report") else {
            self.isLoading = false
            self.errorMessage = "Invalid API URL."
            return
        }
        
        let reportData: [String: Any] = [
            "title": title,
            "body": body,
            "mediaIds": mediaIds,
            "regionId": regionId
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: reportData, options: []) else {
            self.isLoading = false
            self.errorMessage = "Failed to serialize report data."
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            self.isLoading = false
            if let error = error {
                self.errorMessage = "Failed to report: \(error.localizedDescription)"
                return
            }
            
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                self.successMessage = "Report submitted successfully: \(responseString)"
            } else {
                self.errorMessage = "Unknown error occurred."
            }
        }.resume()
    }
}
