//
//  HomeScreenView.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import SwiftUI

struct HomeScreenView<ViewModel: HomeViewModelProtocol>: View {
    
    let user: GoogleUser?
    @StateObject var viewModel: ViewModel
    
    init(user: GoogleUser?, viewModel: ViewModel) {
        self.user = user
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        VStack(spacing: 8) {
            if let user = user {
                Text("Uer Info")
                    .font(.largeTitle)
                
                AsyncImage(url: URL(string: user.picture)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "exclamationmark.triangle")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 200, height: 200)
                
                Text(user.name)
                    .font(.largeTitle)
                
                Text(user.email)
                    .font(.title2)
                
                Button {
                    viewModel.send(.signOut)
                } label: {
                    Text("Sign Out")
                        .foregroundStyle(.white)
                        .padding()
                        .background(.primary)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 8)
                        )
                }

            } else {
                Text("Hello world")
            }
            
        }
    }
}

#Preview {
    HomeScreenView(user: nil, viewModel: HomeViewModel(authenManager: AuthenticationManager()))
}
