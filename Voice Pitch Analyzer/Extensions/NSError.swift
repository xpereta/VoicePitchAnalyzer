//
//  NSError.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/5/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation

extension NSError {

    static func withMessage(_ message: String) -> NSError {
        return NSError(domain: "core", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
