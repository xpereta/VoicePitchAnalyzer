//
//  RecordingManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/4/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import Foundation

protocol RecordingManagerDelegate {
    func recordingManager(didUpdateRemainingTime time: String?)
    func recordingManager(didUpdateRecordingState isRecording: Bool)
    func recordingManager(didUpdateTimer timerDidStop: Bool)
}

class RecordingManager {
    
    private var timer: Timer?
    private var remainingTime: Float = 60 {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.recordingManager(didUpdateRemainingTime: strongSelf.getFormattedRemainingTime())
            }
        }
    }
    
    private var isRecording: Bool = false {
        didSet {
            setState(isRecording: isRecording)
        }
    }

    public var delegate: RecordingManagerDelegate?
    
    // MARK: - Public
    
    public func toggleRecordingState() {
        isRecording = !isRecording
    }
    
    // MARK: - Private
    
    /** Observer function called when isRecording state changes */
    private func setState(isRecording: Bool) {
        
        if isRecording {
            startRecording()
        } else {
            stopRecording()
        }
    }
    
    /** Returns formatted remaining time used on HomeViewController */
    private func getFormattedRemainingTime() -> String {
        
        let calculatedTime = Int(remainingTime)
        
        if calculatedTime == 60 {
            return "01:00"
        }
        
        if calculatedTime < 10 {
            return "00:0\(calculatedTime)"
        }
        
        return "00:\(calculatedTime)"
    }
    
    /** Starts recording timer and updates the Delegate to change the record button on HomeViewController */
    private func startRecording() {
        
        startTimer()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.recordingManager(didUpdateRecordingState: true)
        }
    }
    
    /** Stops and reset time and updates the Delegate to change the record button on HomeViewController */
    private func stopRecording() {
        
        remainingTime = 60
        stopTimer()
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.recordingManager(didUpdateRecordingState: false)
        }
    }
    
    /** Timer to update remaining time and automatically stop after 60 seconds. */
    private func startTimer() {

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            
            guard let strongSelf = self else { return }
            strongSelf.remainingTime -= 0.1
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.recordingManager(didUpdateTimer: false)
            }
            
            if strongSelf.remainingTime <= 0 {
                strongSelf.stopRecording()
            }
        }
    }
    
    /** Stops and reset timer. */
    private func stopTimer() {
        
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.recordingManager(didUpdateRemainingTime: nil)
            self?.delegate?.recordingManager(didUpdateTimer: true)
        }
    }
}
