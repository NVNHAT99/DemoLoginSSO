//
//  HomeViewModel.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

protocol HomeViewModelProtocol: ObservableObject {
    func send(_ intend: HomeViewIntend)
}

final class HomeViewModel: HomeViewModelProtocol {
    private let authenManager: any AuthenticationManaging
    
    init(authenManager: any AuthenticationManaging) {
        self.authenManager = authenManager
    }
    
    func send(_ intend: HomeViewIntend) {
        switch intend {
        case .signOut:
            self.signOut()
        }
    }
    
    private func signOut() {
        Task {
            await authenManager.signOut()
        }
    }
}
