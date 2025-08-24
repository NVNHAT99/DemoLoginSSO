//
//  NetworkManager.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        session = URLSession(configuration: config)
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard let url = URL(string: endpoint.url) else {
            throw NetworkingError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = endpoint.timeout ?? 30
        
        
        endpoint.headerParameters?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let bodyParameters = endpoint.bodyParameters {
            if let contentType = endpoint.headerParameters?["Content-Type"],
               contentType == "application/x-www-form-urlencoded" {
                // Encode as form-urlencoded
                let formBody = bodyParameters
                    .map { "\($0.key)=\("\($0.value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
                    .joined(separator: "&")
                request.httpBody = formBody.data(using: .utf8)
            } else {
                // Default to JSON
                request.httpBody = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unknown(URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkingError.serverError(statusCode: httpResponse.statusCode, message: message)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkingError.decodingError(error)
        }
    }
}
