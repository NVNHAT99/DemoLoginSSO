//
//  LoginEndpoint.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

enum LoginEndpoint {
    case exchangeCode(code: String, codeVerifier: String)
    case refreshToken(refreshToken: String)
    case fetchUserInfo(accessToken: String)
}

extension LoginEndpoint: APIEndpoint {
    
    var url: String {
        switch self {
        case .exchangeCode(let code, let codeVerifier):
            return "https://oauth2.googleapis.com/token"
        case .refreshToken(let refreshToken):
            return "https://oauth2.googleapis.com/token"
        case .fetchUserInfo(let accessToken):
            return "https://www.googleapis.com/oauth2/v2/userinfo"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .exchangeCode, .refreshToken: return .POST
        case .fetchUserInfo: return .GET
        }
    }
    
    var headerParameters: [String : String]? {
        switch self {
        case .exchangeCode, .refreshToken:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        case let .fetchUserInfo(token):
            return ["Authorization": "Bearer \(token)"]
        }
    }
    
    var bodyParameters: [String : Any]? {
        switch self {
        case let .exchangeCode(code, verifier):
            return [
                "code": code,
                "client_id": Constants.SSOGoogleConstants.clientId,
                "redirect_uri": Constants.SSOGoogleConstants.redirectUri,
                "grant_type": "authorization_code",
                "code_verifier": verifier
            ]
        case let .refreshToken(refreshToken):
            return [
                "client_id": Constants.SSOGoogleConstants.clientId,
                "grant_type": "refresh_token",
                "refresh_token": refreshToken
            ]
        case .fetchUserInfo:
            return nil
        }
    }
    
    var timeout: TimeInterval? {
        return 30
    }
}
