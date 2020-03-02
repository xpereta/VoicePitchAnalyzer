//
//  Serializable.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import Wrap
import SwiftyJSON

protocol Serializable {
    var serialized: WrappedDictionary { get }
    var uuid: String { get }
    static func getAll(jsonArray: [JSON]) -> [Serializable]
    static func initialize(json: JSON) -> Serializable
}
