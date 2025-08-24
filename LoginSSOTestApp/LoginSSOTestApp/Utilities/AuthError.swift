//
//  AuthError.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case refreshFailed
    case noToken
    case tokenExchangeFailed(String)
    case invalidAuthResult
    case invalidResponse
    case userCanceled
    case networkError(Error)
    case keychainError(String)
}
