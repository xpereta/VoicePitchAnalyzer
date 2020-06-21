//
//  AuthManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 6/21/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import AuthenticationServices
import FirebaseAuth

protocol AuthManagerDelegate: class {
    func authManager(stateDidChange user: User?)
    func authManager(didFailWith errorMessage: String)
}

class AuthManager {

    public weak var delegate: AuthManagerDelegate?

    init() {
        setAuthObserver()
    }

    // MARK: - Public

    /// Used for user action Apple Sing In
    public func auth(_ token: OAuthCredential, completion: @escaping (Bool) -> Void) {

        Auth.auth().signIn(with: token) { [weak self] (_, error) in
            let result = AuthResult(error, false)
            self?.onAuthCompletion(result, completion)
        }
    }

    /// Used for background login
    public func login(_ vendorID: String, completion: @escaping (Bool) -> Void) {

        let email = "\(vendorID)@voicepitchanalyzer.app"
        let password = vendorID

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
            let result = AuthResult(error, false)
            self?.onAuthCompletion(result, completion)
        }
    }

    /// Used for background registration
    public func signup(_ vendorID: String, completion: @escaping (Bool) -> Void) {

        let email = "\(vendorID)@voicepitchanalyzer.app"
        let password = vendorID

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (_, error) in
            let result = AuthResult(error, false)
            self?.onAuthCompletion(result, completion)
        }
    }

    // MARK: - Private

    private func onAuthCompletion(_ result: AuthResult, _ completion: (Bool) -> Void) {

        var success: Bool = false

        if let error = result.error {

            print("onAuthCompletion error: \(error)")

            if result.checkRegistrationStatus {

                var message = "There is no user record corresponding"
                message += " to this identifier. "
                message += "The user may have been deleted."

                if error.localizedDescription == message {

                    /**
                     From here on success is used as a flag for:
                     "Needs registration"
                     */
                    success = true
                }

            } else {
                success = false
            }

        } else {
            print("onAuthCompletion success")
        }

        completion(success)
    }

    private func setAuthObserver() {

        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in

            if let user = user, let email = user.email {
                self?.delegate?.authManager(stateDidChange: user)
                print("Auth successfull \(email)")
            }
        }
    }
}

struct AuthResult {

    // Auth Error
    let error: Error?

    /**
     Whether or not we want to check if the user is already registered.
     It's false when we perform the manual Apple Sign In
     It's true on the background login with vendorID
     */
    let checkRegistrationStatus: Bool

    init(_ error: Error?, _ checkIsDesired: Bool) {
        self.error = error
        self.checkRegistrationStatus = checkIsDesired
    }
}
