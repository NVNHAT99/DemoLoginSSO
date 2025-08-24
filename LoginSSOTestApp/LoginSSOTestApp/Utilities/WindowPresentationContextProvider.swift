//
//  WindowPresentationContextProvider.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation
import AuthenticationServices
import UIKit

// MARK: - Window Presentation Context Provider
final class WindowPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    
    @MainActor
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}
