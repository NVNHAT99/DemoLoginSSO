//
//  TokenResponse.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

struct TokenResponse: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let token_type: String
    
    var expirationDate: Date {
        return Date().addingTimeInterval(TimeInterval(expires_in))
    }
    
    var isExpired: Bool {
        return expirationDate <= Date()
    }
    
    var shouldRefresh: Bool {
        return expirationDate.timeIntervalSinceNow <= 300
    }
}
