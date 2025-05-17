import Foundation

class FileUploadManager {
    
    // Function to upload file to server and get fileId and fileUrl
    static func uploadMedia(fileURL: URL, completion: @escaping (String?, String?, Error?) -> Void) {
        
        // Get the API URL from environment variables
        let apiBase = EnvManager.shared.require("API_URL")
        guard let url = URL(string: "\(apiBase)/file") else {
            completion(nil, nil, NSError(domain: "InvalidURL", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for file upload"]))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Create boundary for multipart data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create multipart form data body
        var body = Data()
        
        // Add file data
        let filename = fileURL.lastPathComponent
        let fileData = try? Data(contentsOf: fileURL)
        
        if let fileData = fileData {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: application/octet-stream\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        // Make the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }

            // Handle server response
            guard let data = data else {
                completion(nil, nil, NSError(domain: "NoData", code: 400, userInfo: [NSLocalizedDescriptionKey: "No data received from server."]))
                return
            }
            
            do {
                // Decode the server response
                let responseData = try JSONDecoder().decode(FileUploadResponse.self, from: data)
                completion(responseData.fileId, responseData.fileUrl, nil)
            } catch {
                completion(nil, nil, error)
            }
        }.resume()
    }
}

// Model to parse the response from file upload
struct FileUploadResponse: Codable {
    let fileId: String
    let fileUrl: String
}
