//
//  LoginSSOTestAppApp.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import SwiftUI

@main
struct LoginSSOTestAppApp: App {
    @StateObject private var authManager = AuthenticationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
