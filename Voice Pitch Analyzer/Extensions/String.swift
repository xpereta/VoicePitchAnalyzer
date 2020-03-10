//
//  String.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation

extension String {
    
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
