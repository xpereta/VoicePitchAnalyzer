//
//  Log.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import FirebaseCrashlytics
import FirebaseAnalytics

class Log {
    
    // MARK: - Public
    
    static public func record(_ error: Error, at function: String) {
        
        print("Error at \(function): \(error)")
        Crashlytics.crashlytics().record(error: error)
    }
    
    static public func event(_ event: LogEvent) {
        
        let parameters = [
            "date": Date().iso8601
        ]
        
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}

enum LogEvent: String {
    case AppStart = "appStart"
    case RecordStart = "recordStart"
    case RecordStop = "recordStop"
    case PressHelpButton = "pressHelpButton"
}
