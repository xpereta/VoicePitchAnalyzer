//
//  File.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 2/28/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation
import FirebaseFirestore
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
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }

        setResultsObserver(userID: identifierForVendor.uuidString)
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

    /** Observer for the result history on Firebase. */
    // MARK: - TODO: Add pagination to support more than 20 results
    private func setResultsObserver(userID: String) {

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
