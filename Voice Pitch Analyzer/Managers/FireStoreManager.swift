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

class FireStoreManager {
    
    private let firestore = Firestore.firestore()
    
    // MARK: - Public
    
    public func getLastResults(userID: String, completion: @escaping ([RecorderResult]) -> ()) {
        
        firestore
        .collection("Results")
        .document(userID)
        .collection("Results")
        .getDocuments { (querySnapshot, error) in
            
            guard error == nil else {
                Log.shared.record(error!, at: #function)
                return
            }
                
            let results = querySnapshot!.documents.map { (element: QueryDocumentSnapshot) in
                return RecorderResult(json: JSON(element.data()))
            }
            
            completion(results)
        }
    }
    
    public func setLastResult(_ result: RecorderResult) {
                
        var reference: DocumentReference? = nil
        
        reference = firestore
        .collection("Results")
        .document(result.userID)
        .collection("Results")
        .document(result.uuid)
            
        reference?.setData(result.serialized) { error in
            
            guard error == nil else {
                Log.shared.record(error!, at: #function)
                return
            }
            
            print("Document added with ID: \(reference!.documentID)")
        }
    }
}
