//
//  MicrophoneAccessManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 4/7/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import Foundation
import AVFoundation

protocol MicrophoneAccessManagerDelegate: class {
    func microphoneAccessManager(didChangeAuthorizationStatusTo status: AVAuthorizationStatus, isAuthorized: Bool)
}

class MicrophoneAccessManager {

    public weak var delegate: MicrophoneAccessManagerDelegate?
    private var microphoneAccessIsDenied: Bool = false

    // MARK: - Public

    public func checkAuthorizationStatus() {

        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        let isAuthorized = status == .authorized
        microphoneAccessIsDenied = status == .denied
        delegate?.microphoneAccessManager(didChangeAuthorizationStatusTo: status, isAuthorized: isAuthorized)
    }

    public func requestAuthorization() {
        
        print("requestAuthorization")

        if microphoneAccessIsDenied {
            openSettings()
        } else {
            requestAccess()
        }
    }
    
    // MARK: - Private
    
    private func requestAccess() {
        
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            print("requestAccess granted: ", granted)
            self?.checkAuthorizationStatus()
        }
    }
    
    private func openSettings() {
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        guard UIApplication.shared.canOpenURL(settingsUrl) else {
            return
        }

        UIApplication.shared.open(settingsUrl)
    }
}

//AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
