//
//  NetworkManager.swift
//  SpyneImage
//
//  Created by Hemant Sharma on 10/11/24.
//

import Foundation

// MARK: - NetworkManager
import Foundation

class NetworkManager: NSObject {
    
    static let shared = NetworkManager() // Singleton for global access
    
    private override init() {}  // Ensure that the instance is created only once
    
    // Base URL
    private let baseURL = "https://www.clippr.ai/api/"
    
    // Generic function to make API requests with background upload (multipart form-data)
    func uploadImage(at imagePath: String,
                     completion: @escaping (Result<String, Error>) -> Void) {
        
        // URL Encode the image path to make sure special characters and spaces are handled
        guard let encodedImagePath = imagePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            completion(.failure(NetworkError.encodingFailed))
            return
        }
        
        // Construct the URL for the upload API
        guard let url = URL(string: baseURL + "upload") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Prepare the file data to be uploaded
        let fileURL = URL(fileURLWithPath: imagePath)
        
        // Create a unique boundary string for multipart form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        
        // Prepare the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Create the body for the multipart request
        var body = Data()
        
        let fileName = fileURL.lastPathComponent
        
        // Add the image data to the multipart body
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: image/png\r\n\r\n")
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        // Attach the body to the request
        request.httpBody = body
        
        // Print the curl equivalent command (without the --header part)
        let curlCommand = """
        curl --location '\(url)' \\
        --form 'image=@\"\(encodedImagePath)\"'
        """
        print("Curl Command:\n\(curlCommand)")
        
        // Create a URLSession task to send the request
        let task = URLSession.shared.uploadTask(with: request, from: body) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Parse the response data
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            //parse the response into a string or appropriate model (depending on the API response)
            if let responseString = String(data: data, encoding: .utf8) {
                completion(.success(responseString))  // response is a simple string (basically an URL)
            } else {
                completion(.failure(NetworkError.decodingFailed))
            }
        }
        task.resume()
    }
}

// MARK: - Network Errors
enum NetworkError: Error {
    case invalidURL
    case encodingFailed
    case noData
    case decodingFailed
    case serverError
    case fileNotFound
    case failedToLoadImage
}

