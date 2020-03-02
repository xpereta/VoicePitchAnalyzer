//
//  Result.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import Wrap
import SwiftyJSON

class RecorderResult: Serializable {
    
    var serialized: WrappedDictionary {
        return try! Wrap.wrap(self)
    }
    
    static func getAll(jsonArray: [JSON]) -> [Serializable] {
        return jsonArray.map { element in
            self.init(json: element)
        }
    }
    
    static func initialize(json: JSON) -> Serializable {
        return self.init(json: json)
    }
    
    var uuid: String
    var userID: String
    var date: Date
    var minAverage: Double
    var maxAverage: Double
    
    required init(json: JSON) {
        
        print("date: \(json["date"].stringValue)")
        
        self.uuid = json["uuid"].stringValue
        self.userID = json["userID"].stringValue
        self.date = json["date"].stringValue.dateFromISO8601!
        self.minAverage = json["minAverage"].doubleValue
        self.maxAverage = json["maxAverage"].doubleValue
    }
    
    convenience init(minAverage: Double, maxAverage: Double, userID: String) {
        let now = Date()
        self.init(json:  [
            "uuid": now.millisecondsSince1970,
            "date": now.iso8601,
            "userID": userID,
            "minAverage": minAverage,
            "maxAverage": maxAverage
        ])
    }
}

// MARK: - Wrap Customization
extension RecorderResult: WrapCustomizable {
    
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: Formatter.iso8601).wrap(object: self)
    }
}
