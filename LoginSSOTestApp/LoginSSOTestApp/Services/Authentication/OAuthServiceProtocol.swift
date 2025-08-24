//
//  OAuthServiceProtocol.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation
import AuthenticationServices

protocol OAuthServiceProtocol {
    var provider: AuthProvider { get }
    func authenticate(presentationContext: ASWebAuthenticationPresentationContextProviding) async throws -> AuthResult
}
