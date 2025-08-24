//
//  Constants.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

struct Constants {
    struct SSOGoogleConstants {
        static let clientId = "401701987987-324sup8i99ol282kmdkdedb2jv7dffsb.apps.googleusercontent.com"
        static let redirectUri = "Demo.nothing.LoginSSOTestApp:/auth"
        static let callbackURLScheme = "Demo.nothing.LoginSSOTestApp"
        static let scope = "openid profile email"
        static let googleTokenKey = "googleTokenKey"
        static let userKey = "userKey"
        static let authURL = "https://accounts.google.com/o/oauth2/v2/auth"
    }
}
