//
//  NetworkingError.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

enum NetworkingError: Error, LocalizedError {
    case invalidURL
    case timeout
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .timeout:
            return "Request timed out"
        case let .serverError(code, message):
            return "Server returned error \(code): \(message)"
        case let .decodingError(err):
            return "Failed to decode response: \(err.localizedDescription)"
        case let .unknown(err):
            return err.localizedDescription
        }
    }
}
