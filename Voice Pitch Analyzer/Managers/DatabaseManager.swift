//
//  File.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 2/28/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import FirebaseFirestore
import SwiftyJSON

protocol DatabaseManagerDelegate {
    func databaseManager(didLoadData data: [RecorderResult])
    func databaseManager(didReceiveError error: Error)
    func databaseManager(didUploadResultWithID documentID: String)
}

class DatabaseManager {
    
    private let firestore = Firestore.firestore()
    
    public var delegate: DatabaseManagerDelegate?
    public var results: [RecorderResult] = []
    
    // MARK: - Public
    
    public func configure() {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }
        
        setResultsObserver(userID: identifierForVendor.uuidString)
    }
    
    public func getResults() {
        delegate?.databaseManager(didLoadData: results)
    }
    
    public func setLastResult(_ result: RecorderResult) {
                
        var reference: DocumentReference? = nil
        
        reference = firestore
            .collection("Results")
            .document(result.userID)
            .collection("Results")
            .document(result.uuid)
            
        reference?.setData(result.serialized) { [weak self] error in
            
            guard error == nil else {
                Log.record(error!, at: #function)
                return
            }
            
            self?.delegate?.databaseManager(didUploadResultWithID: reference!.documentID)
        }
    }
    
    // MARK: - Private
    
    private func setResultsObserver(userID: String) {
        
        firestore
            .collection("Results")
            .document(userID)
            .collection("Results")
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
