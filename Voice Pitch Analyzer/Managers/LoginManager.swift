//
//  LoginManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 6/13/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import AuthenticationServices

protocol LoginManagerDelegate: class {
    func loginManager(didComplete userIdentifier: String?)
}

class LoginManager: NSObject {

    public weak var delegate: LoginManagerDelegate?
    public var parentController: UIViewController?

    // MARK: - Public

    public func requestLogin() {

        guard #available(iOS 13, *) else {
            return
        }

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])

        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension LoginManager: ASAuthorizationControllerDelegate {

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIDCredential.user
            delegate?.loginManager(didComplete: userIdentifier)
        default:
            break
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension LoginManager: ASAuthorizationControllerPresentationContextProviding {

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return parentController!.view.window!
    }
}
