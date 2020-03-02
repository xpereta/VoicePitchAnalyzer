//
//  File.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 2/28/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FireStoreManager {
    
    private let firestore = Firestore.firestore()
    
    // MARK: - Public
    
    public func getLastResult(userID: String, completion: (String) -> ()) {
        
        var reference: DocumentReference? = nil
        
        reference = firestore
        .collection("Results")
        .document(userID)
            
        reference?.getDocument(completion: { (document, error) in
                
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        })
    }
    
    public func setLastResult(userID: String, min minAverage: Double, max maxAverage: Double) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let payload = [
            "userID": userID,
            "minAverage": minAverage,
            "maxAverage": maxAverage,
            "date": formatter.string(from: Date())
        ] as [String : Any]
        
        var reference: DocumentReference? = nil
        
        reference = firestore
        .collection("Results")
        .document(userID)
            
        reference?.setData(payload) { error in
            
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added with ID: \(reference!.documentID)")
            }
        }
    }
}
