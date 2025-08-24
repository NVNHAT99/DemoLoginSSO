//
//  LoginScreenView.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import SwiftUI

struct LoginScreenView<ViewModel: LoginViewModelProtocol>: View {
    
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack {

                Text("IOS Interview Test")
                
                Button {
                    self.viewModel.send(.loginWithGoogle)
                } label: {
                    Text("Login With Google")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.primary)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 8)
                        )
                }
            }
            
            if viewModel.state.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }// Zstack
    }
}

#Preview {
    LoginScreenView(viewModel: LoginViewModel(authManager: AuthenticationManager()))
}
