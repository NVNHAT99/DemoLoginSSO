//
//  LoginScreenState.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

enum LoginNavigation {
    case home
}

struct LoginScreenState {
    var isLoading: Bool = false
    var navgiation: LoginNavigation? = nil
    var errorMessage: String? = nil
}

