//
//  AuthModel.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

enum AuthProvider: String, CaseIterable {
    case google = "google"
    var displayName: String {
        switch self {
        case .google: return "Google"
        }
    }
}

struct AuthResult {
    let code: String
    let codeVerifier: String?
    let provider: AuthProvider
}
