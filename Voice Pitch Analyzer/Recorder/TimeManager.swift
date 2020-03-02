//
//  TimeManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation

class TimeManager {
    
    private var remainingTime: Float = 60
    
    // MARK: - Public
    
    public func getRemainingTime() -> Int {
        return Int(remainingTime)
    }
    
    public func reduceTime(by seconds: Float?) {
        
        guard let seconds = seconds else {
            remainingTime = 60
            return
        }
        
        remainingTime -= seconds
    }
}
