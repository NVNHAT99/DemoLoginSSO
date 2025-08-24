//
//  AuthenticationManager.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation
import SwiftUI
import AuthenticationServices

protocol AuthenticationManaging: ObservableObject {
    var isAuthenticated: Bool { get }
    var isLoading: Bool { get }
    var currentToken: TokenResponse? { get }
    var currentUser: GoogleUser? { get }
    var errorMessage: String? { get }
    
    func checkAuthenticationStatus()
    func signInWithGoogle() async
    func signIn(with provider: AuthProvider) async
    func signOut() async
}


// MARK: - AuthTokenProvider
protocol AuthTokenProvider: AnyObject {
    /// Trả về access token hợp lệ, refresh nếu cần
    func getValidToken() async -> String?
}

// MARK: - AuthenticationManager
// TODO: - This class have many harcode, need to refactor for logic mutiple authen
final class AuthenticationManager: AuthenticationManaging, AuthTokenProvider {
    
    @Published private(set) var isAuthenticated = false
    @Published private(set) var isLoading = true
    @Published private(set) var currentToken: TokenResponse?
    @Published private(set) var currentUser: GoogleUser?
    @Published private(set) var errorMessage: String?
    
    private let keychainManager: KeychainManagerProtocol
    private let googleAuthService: OAuthServiceProtocol
    private let networkManager: NetworkManagerProtocol
    private let presentationContextProvider = WindowPresentationContextProvider()
    
    init(
        keychainManager: KeychainManagerProtocol = KeychainManager.shared,
        googleAuthService: OAuthServiceProtocol = GoogleAuthService(),
        networkManager: NetworkManagerProtocol = NetworkManager.shared
    ) {
        self.keychainManager = keychainManager
        self.googleAuthService = googleAuthService
        self.networkManager = networkManager
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        Task {
            isLoading = true
            errorMessage = nil
            
            guard let token = keychainManager.readObject(for: Constants.SSOGoogleConstants.googleTokenKey, as: TokenResponse.self) else {
                await updateAuthState(isAuthenticated: false)
                return
            }
            
            if !token.isExpired {
                let user = keychainManager.readObject(for: Constants.SSOGoogleConstants.userKey, as: GoogleUser.self)
                await restoreSession(token: token, user: user)
            } else if let refreshToken = token.refresh_token {
                await refreshSession(refreshToken: refreshToken)
            } else {
                await clearSessionAndRequireLogin()
            }
        }
    }
    
    func signInWithGoogle() async {
        await signIn(with: .google)
    }
    
    @MainActor
    func signIn(with provider: AuthProvider) async {
        do {
            isLoading = true
            errorMessage = nil
            
            let authService = getAuthService(for: provider)
            let authResult = try await authService.authenticate(presentationContext: presentationContextProvider)
            
            let tokenResponse = try await exchangeCodeForToken(
                code: authResult.code,
                codeVerifier: authResult.codeVerifier ?? ""
            )
            
            let user = try await fetchUserInfo(token: tokenResponse.access_token, provider: provider)
            
            try await completeSuccessfulLogin(token: tokenResponse, user: user)
        } catch {
            await handleAuthError(error)
        }
    }
    
    func signOut() async {
        keychainManager.delete(for: Constants.SSOGoogleConstants.googleTokenKey)
        keychainManager.delete(for: Constants.SSOGoogleConstants.userKey)
        await updateAuthState(isAuthenticated: false, token: nil, user: nil)
    }
    
    // MARK: - Token Handling
    func exchangeCodeForToken(code: String, codeVerifier: String) async throws -> TokenResponse {
        try await networkManager.request(LoginEndpoint.exchangeCode(code: code, codeVerifier: codeVerifier))
    }
    
    func refreshAccessToken(refreshToken: String) async throws -> TokenResponse {
        try await networkManager.request(LoginEndpoint.refreshToken(refreshToken: refreshToken))
    }
    
    // MARK: - Refresh token an toàn
    func refreshTokenIfNeeded() async -> TokenResponse? {
        guard let token = currentToken,
              token.shouldRefresh,
              let refreshToken = token.refresh_token else { return currentToken }
        
        do {
            let newToken = try await refreshAccessToken(refreshToken: refreshToken)
            try keychainManager.saveObject(newToken, for: Constants.SSOGoogleConstants.googleTokenKey)
            let user = currentUser ?? keychainManager.readObject(for: Constants.SSOGoogleConstants.userKey, as: GoogleUser.self)
            await updateAuthState(isAuthenticated: true, token: newToken, user: user)
            return newToken
        } catch {
            print("Refresh failed: \(error)")
            await clearSessionAndRequireLogin()
            return nil
        }
    }
    
    func getValidToken() async -> String? {
        return await refreshTokenIfNeeded()?.access_token
    }
    
    // MARK: - Private Helpers
    private func getAuthService(for provider: AuthProvider) -> OAuthServiceProtocol {
        switch provider {
        case .google: return googleAuthService
        }
    }
    
    private func restoreSession(token: TokenResponse, user: GoogleUser?) async {
        let finalUser: GoogleUser?
        if let user = user {
            finalUser = user
        } else {
            // Hard code here google provider
            finalUser = try? await fetchUserInfo(token: token.access_token, provider: .google)
        }
        await updateAuthState(isAuthenticated: true, token: token, user: finalUser)
    }
    
    private func refreshSession(refreshToken: String) async {
        _ = await refreshTokenIfNeeded()
    }
    
    private func clearSessionAndRequireLogin() async {
        keychainManager.delete(for: Constants.SSOGoogleConstants.googleTokenKey)
        keychainManager.delete(for: Constants.SSOGoogleConstants.userKey)
        await updateAuthState(isAuthenticated: false)
    }
    
    // TODO: - hard code here
    private func completeSuccessfulLogin(token: TokenResponse, user: GoogleUser) async throws {
        try keychainManager.saveObject(token, for: Constants.SSOGoogleConstants.googleTokenKey)
        try keychainManager.saveObject(user, for: Constants.SSOGoogleConstants.userKey)
        await updateAuthState(isAuthenticated: true, token: token, user: user)
    }
    
    @MainActor
    private func updateAuthState(
        isAuthenticated: Bool,
        token: TokenResponse? = nil,
        user: GoogleUser? = nil
    ) async {
        self.isAuthenticated = isAuthenticated
        self.currentToken = token
        self.currentUser = user
        self.isLoading = false
        self.errorMessage = nil
    }
    
    @MainActor
    private func handleAuthError(_ error: Error) async {
        isLoading = false
        let authError: AuthError
        if let auth = error as? AuthError { authError = auth }
        else if let asWebAuth = error as? ASWebAuthenticationSessionError {
            authError = asWebAuth.code == .canceledLogin ? .userCanceled : .networkError(error)
        } else { authError = .networkError(error) }
        
        errorMessage = authError.localizedDescription
        if case .userCanceled = authError { errorMessage = nil }
        print("Auth error: \(error)")
    }
    
    private func fetchUserInfo(token: String, provider: AuthProvider) async throws -> GoogleUser {
        switch provider {
        case .google:
            return try await networkManager.request(LoginEndpoint.fetchUserInfo(accessToken: token))
        }
    }
}
