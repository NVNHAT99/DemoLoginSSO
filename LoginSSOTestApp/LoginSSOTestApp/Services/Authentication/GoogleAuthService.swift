//
//  GoogleAuthService.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//


import Foundation
import AuthenticationServices
import CryptoKit
import UIKit

final class GoogleAuthService: OAuthServiceProtocol {
    
    let provider: AuthProvider = .google
    
    private let clientId = Constants.SSOGoogleConstants.clientId
    private let redirectUri = Constants.SSOGoogleConstants.redirectUri
    
    func authenticate(presentationContext: ASWebAuthenticationPresentationContextProviding) async throws -> AuthResult {
        let codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)
        
        var components = URLComponents(string: Constants.SSOGoogleConstants.authURL)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "scope", value: Constants.SSOGoogleConstants.scope),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "access_type", value: "offline")
        ]
        
        guard let authURL = components.url else {
            throw URLError(.badURL)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: authURL,
                callbackURLScheme: Constants.SSOGoogleConstants.callbackURLScheme
            ) { callbackURL, error in
                if let error = error {
                    // Handle user cancelation gracefully
                    if let authError = error as? ASWebAuthenticationSessionError,
                       authError.code == .canceledLogin {
                        continuation.resume(throwing: AuthError.userCanceled)
                    } else {
                        continuation.resume(throwing: error)
                    }
                    return
                }
                
                guard let url = callbackURL,
                      let code = URLComponents(string: url.absoluteString)?
                        .queryItems?.first(where: { $0.name == "code" })?.value else {
                    continuation.resume(throwing: AuthError.invalidAuthResult)
                    return
                }
                
                let result = AuthResult(
                    code: code,
                    codeVerifier: codeVerifier,
                    provider: .google
                )
                continuation.resume(returning: result)
            }
            
            session.presentationContextProvider = presentationContext
            session.start()
        }
    }
    
    // MARK: - PKCE helpers
    private func generateCodeVerifier() -> String {
        let chars = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return String((0..<128).map { _ in chars.randomElement()! })
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        let data = SHA256.hash(data: verifier.data(using: .utf8)!)
        let hash = Data(data)
        return hash.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
