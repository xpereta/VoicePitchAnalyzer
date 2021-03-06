//
//  Result.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation
import Wrap
import SwiftyJSON

class RecorderResult: Serializable {

    /** Returns object as JSON for Firebase */
    var serialized: WrappedDictionary? {
        do {
            return try Wrap.wrap(self)
        } catch let error {
            Log.record(error, at: #function)
            return nil
        }

    }

    /** Inits object from JSON */
    static func initialize(json: JSON) -> Serializable {
        return self.init(json: json)
    }

    var uuid: String
    var userID: String
    var date: Date
    var minAverage: Double
    var maxAverage: Double

    required init(json: JSON) {

        self.uuid = json["uuid"].stringValue
        self.userID = json["userID"].stringValue
        self.date = json["date"].stringValue.dateFromISO8601!
        self.minAverage = json["minAverage"].doubleValue
        self.maxAverage = json["maxAverage"].doubleValue
    }

    convenience init(minAverage: Double, maxAverage: Double, userID: String) {
        let now = Date()
        self.init(json: [
            "uuid": now.millisecondsSince1970,
            "date": now.iso8601,
            "userID": userID,
            "minAverage": minAverage,
            "maxAverage": maxAverage
        ])
    }

    // MARK: - Public

    public func getFormattedMin() -> String {
        return "\(Int(minAverage))hz"
    }

    public func getFormattedMedian() -> String {
        return "\(Int((Int(minAverage) + Int(maxAverage)) / 2))hz"
    }

    public func getFormattedMax() -> String {
        return "\(Int(maxAverage))hz"
    }

    public func getFormattedMonth(using formatter: DateFormatter) -> String {
        formatter.dateFormat = "MMM"
        return formatter.string(from: date)
    }

    public func getFormatteDay(using formatter: DateFormatter) -> String {
        formatter.dateFormat = "dd"
        return formatter.string(from: date)
    }
}

// MARK: - Wrap Customization
extension RecorderResult: WrapCustomizable {

    /** Function to mutate the JSON result of 'serialized' and adjust date object as iso8601 */
    func wrap(context: Any?, dateFormatter: DateFormatter?) -> Any? {
        return try? Wrapper(context: context, dateFormatter: Formatter.iso8601).wrap(object: self)
    }
}
