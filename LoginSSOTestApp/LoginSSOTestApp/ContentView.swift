//
//  ContentView.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    var body: some View {
        VStack {
            if authManager.isAuthenticated {
                HomeScreenView(user: authManager.currentUser, viewModel: HomeViewModel(authenManager: authManager))
            } else {
                LoginScreenView(viewModel: LoginViewModel(authManager: authManager))
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager())
}
