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

    private let authManager: AuthManager
    private let firestore = Firestore.firestore()
    private var user: User?

    public weak var delegate: DatabaseManagerDelegate?
    public var results: [RecorderResult] = []

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Public

    public func configure() {

        /** Using the vendorID to support none registratered users with Firebase */
        guard let vendorID = getVendorID() else {
            return
        }

        authManager.login(vendorID) { [weak self] isMissingRegistration in

            if isMissingRegistration == true {
                self?.authManager.signup(vendorID) {_ in}
            }
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

    /**
     For Presistent user database, we want to use the background
     registered firebase userID if available.
     If no User has been registered, we want to use the vendorID
     */
    public func getUserID() -> String? {

        if let user = user, let email = user.email {
            return getIdentifierFrom(userEmail: email)
        }

        return getVendorID()
    }

    public func getIdentifierFrom(userEmail email: String) -> String {
        return email.replacingOccurrences(of: "@voicepitchanalyzer.app", with: "")
    }

    // MARK: - Private

    /** Using the vendorID to support none registrated users with Firebase */
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
}

// MARK: - AuthManagerDelegate
extension DatabaseManager: AuthManagerDelegate {

    func authManager(stateDidChange user: User?) {

        self.user = user
        guard let userID = getUserID() else { return }
        setResultsObserver(userID: userID)
    }

    func authManager(didFailWith errorMessage: String) {

    }
}
