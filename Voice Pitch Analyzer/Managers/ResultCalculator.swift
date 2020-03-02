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
    
    public func getAverage(of pitchArray: [Double], getMax: Bool) -> Double {
        
        var sorted = pitchArray
        sorted = sorted.sorted()
        
        let elements = sorted.count / 3
        
        if getMax {
            sorted = Array(sorted.suffix(elements))
        } else {
            sorted = Array(sorted.prefix(elements))
        }

        return calculateAverage(pitches: sorted)
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
