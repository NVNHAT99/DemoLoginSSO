//
//  LoginViewModel.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

protocol LoginViewModelProtocol: ObservableObject {
    var state: LoginScreenState { get }
    func send(_ intend: LoginScreenIntent)
}

final class LoginViewModel: LoginViewModelProtocol {
    @Published private(set) var state: LoginScreenState = .init()
    @Published var errorMessage: String?
    
    private let authManager: any AuthenticationManaging
    
    init(authManager: any AuthenticationManaging) {
        self.authManager = authManager
    }
    
    func send(_ intend: LoginScreenIntent) {
        switch intend {
        case .loginWithGoogle:
            Task {
                await loginWithGoogle()
            }
        }
    }
    
    private func loginWithGoogle() async {
        await MainActor.run {
            state.isLoading = true
            errorMessage = nil
        }
        
        await authManager.signInWithGoogle()
        await MainActor.run {
            state.isLoading = false
        }
    }
}
