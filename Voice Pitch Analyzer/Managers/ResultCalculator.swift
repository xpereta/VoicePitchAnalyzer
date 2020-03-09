//
//  ResultCalculator.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation

class ResultCalculator {
    
    // MARK: - Public
    
    /** Returns the average of the input pitch levels used to display the min/max pitch level */
    public func getAverage(of pitchArray: [Double], getMax: Bool) -> Double {
        
        var sorted = pitchArray
        sorted = sorted.sorted()
        
        let elements = sorted.count / 3
        
        if getMax {
            sorted = Array(sorted.suffix(elements))
        } else {
            sorted = Array(sorted.prefix(elements))
        }

        var result = calculateAverage(pitches: sorted)
        
        if getMax {
            
            /** Edit result back to desired top level of 255 Hz */
            if result > 255 {
                result = 255
            }
            
        } else {
            
            /** Edit result back to desired low level of 85 Hz */
            if result < 85 {
                result = 85
            }
        }
        
        return result
    }
    
    // MARK: - Private

    private func  calculateAverage(pitches:Array<Double>) -> Double {
        var sum = 0.0;
        if (pitches.count != 0) {
            for pitch in pitches {
                sum += pitch;
            }
            return sum / Double(pitches.count);
        }
        return sum;
    }
}
