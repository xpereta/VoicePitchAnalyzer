//
//  File.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 2/28/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftyJSON

protocol DatabaseManagerDelegate: class {
    func databaseManager(didLoadData data: [RecorderResult])
    func databaseManager(didReceiveError error: Error)
    func databaseManager(didUploadResultWithID documentID: String)
}

class DatabaseManager {

    private let firestore = Firestore.firestore()

    public weak var delegate: DatabaseManagerDelegate?
    public var results: [RecorderResult] = []

    // MARK: - Public

    public func configure() {

        /** Using the vendorID to support none registratered users with Firebase */
        guard let vendorID = getVendorID() else {
            return
        }

        getAuthState { [weak self] isAuthenticated in
            guard isAuthenticated else {
                self?.loginUser(vendorID) { registrationIsMissing in
                    if registrationIsMissing == true {
                        self?.signupUser(vendorID)
                    }
                }
                return
            }

            self?.setResultsObserver(userID: vendorID)
        }
    }

    /** Helper to push the existing results down the delegate. */
    public func getResults() {
        delegate?.databaseManager(didLoadData: results)
    }

    /** Upload the current new result to firebase. */
    public func setLastResult(_ result: RecorderResult) {

        var reference: DocumentReference?

        reference = firestore
            .collection("Results")
            .document(result.userID)
            .collection("Results")
            .document(result.uuid)

        guard let serialized = result.serialized else { return }

        reference?.setData(serialized) { [weak self] error in

            guard error == nil else {
                Log.record(error!, at: #function)
                return
            }

            self?.delegate?.databaseManager(didUploadResultWithID: reference!.documentID)
        }
    }

    // MARK: - Private

    /** Using the vendorID to support none registratered users with Firebase */
    private func getVendorID() -> String? {

        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return nil
        }

        return identifierForVendor.uuidString
    }

    /** Observer for the result history on Firebase. */
    // MARK: - TODO: Add pagination to support more than 20 results
    private func setResultsObserver(userID: String) {

        print("Setting ResultsObserver")

        firestore
            .collection("Results")
            .document(userID)
            .collection("Results")
            .order(by: "date")
            .limit(toLast: 20)
            .addSnapshotListener({ [weak self] (querySnapshot, error) in

                guard error == nil else {
                    Log.record(error!, at: #function)
                    self?.delegate?.databaseManager(didReceiveError: error!)
                    return
                }

                let results = querySnapshot!.documents.map { (element: QueryDocumentSnapshot) in
                    return RecorderResult(json: JSON(element.data()))
                }

                self?.results = results
                self?.delegate?.databaseManager(didLoadData: results)
            })
    }

    private func getAuthState(completion: @escaping (Bool) -> Void) {

        Auth.auth().addStateDidChangeListener { (_, user) in

            var isAuthenticated = false

            if let user = user, let email = user.email {
                isAuthenticated = true
                print("Auth successfull \(email)")
            }

            completion(isAuthenticated)
        }
    }

    private func signupUser(_ vendorID: String) {

        let email = "\(vendorID)@voicepitchanalyzer.app"
        let password = vendorID

        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in

            if let error = error {
                print("error: \(error)")
            } else {
                print("SignUp successfull")
            }
        }
    }

    private func loginUser(_ vendorID: String, completion: @escaping (Bool) -> Void) {

        let email = "\(vendorID)@voicepitchanalyzer.app"
        let password = vendorID

        Auth.auth().signIn(withEmail: email, password: password) { (_, error) in

            var registrationIsMissing: Bool = false

            if let error = error {

                if error.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted." {
                    registrationIsMissing = true
                } else {
                    print("Login error: \(error)")
                }

            } else {
                print("Login successfull")
            }

            completion(registrationIsMissing)
        }
    }
}
