//
//  CloudFunctionsManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 6/13/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import Firebase

class CloudFunctionsManager {

    private let functions = Functions.functions()

    // MARK: - Public

    public func getHash(completion: @escaping (String) -> Void) {

        functions.httpsCallable("getHash").call { result, error in

            if let error = error {
                Log.record(error, at: #function)
            }

            if let result = result {
                print("result: \(result.data)")
            }
        }
    }
}
