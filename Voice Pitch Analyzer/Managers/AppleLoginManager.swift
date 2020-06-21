//
//  LoginManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 6/13/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import AuthenticationServices
import FirebaseAuth

protocol AppleLoginManagerDelegate: class {
    func appleLoginManager(didFailWith errorMessage: String)
}

class AppleLoginManager: NSObject {

    private let cloudFunctionsManager: CloudFunctionsManager
    private let authManager: AuthManager
    // Unhashed nonce.
    private var currentNonce: String?

    public weak var delegate: AppleLoginManagerDelegate?
    public var parentController: UIViewController?

    init(cloudFunctionsManager: CloudFunctionsManager,
         authManager: AuthManager) {

        self.cloudFunctionsManager = cloudFunctionsManager
        self.authManager = authManager
    }

    // MARK: - Public

    public func requestLogin(_ onCompletion: @escaping (String) -> Void) {

        guard #available(iOS 13, *) else {
            return
        }

        cloudFunctionsManager.getHash { [weak self] hash in

            guard let strongSelf = self else {
                return
            }

            strongSelf.currentNonce = hash

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.email]
            request.nonce = hash

            let controller = ASAuthorizationController(authorizationRequests: [request])

            controller.delegate = strongSelf
            controller.presentationContextProvider = strongSelf

            controller.performRequests()

            onCompletion(hash)
        }

        /**
         
         userIdentifier: 001285.6bc1ec7ba6ab4ddebcfb3cb643236b8b.2131
         didChangeAuthorizationStatusTo AVAuthorizationStatus isAuthorized: true
         
         userIdentifier: 001285.6bc1ec7ba6ab4ddebcfb3cb643236b8b.2131
         didChangeAuthorizationStatusTo AVAuthorizationStatus isAuthorized: true
         */
    }

    // MARK: - Private

}

// MARK: - ASAuthorizationControllerDelegate
extension AppleLoginManager: ASAuthorizationControllerDelegate {

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            guard let nonce = currentNonce else {
                delegate?.appleLoginManager(didFailWith: "Unknown error, please try again")
                return
            }

            guard let appleIDToken = appleIDCredential.identityToken else {
                delegate?.appleLoginManager(didFailWith: "Unable to fetch identity token, please try again")
                return
            }

            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                delegate?.appleLoginManager(didFailWith: "Unable to serialize token, please try again")
                return
            }

            // Initialize a Firebase credential.
            let token = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )

            authManager.auth(token) { _ in

            }
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return parentController!.view.window!
    }
}
