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
    
    /** Sends custom error messages to Firebase. Crash logs will be send in background. */
    static public func record(_ error: Error, at function: String) {
        
        print("Error at \(function): \(error)")
        Crashlytics.crashlytics().record(error: error)
    }
    
    /** Create error and send to Firebase. */
    static public func recordProblem(_ problem: String, at function: String) {
        
        let error = NSError.withMessage(problem)
        print("Error at \(function): \(error)")
        Crashlytics.crashlytics().record(error: error)
    }
    
    /** Logger for Firebase analytics. */
    static public func event(_ event: LogEvent) {
        
        let parameters = [
            "date": Date().iso8601
        ]
        
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }
}

// MARK: - TODO Add more logging events
enum LogEvent: String {
    case AppStart = "appStart"
    case RecordStart = "recordStart"
    case RecordStop = "recordStop"
    case PressHelpButton = "pressHelpButton"
}
