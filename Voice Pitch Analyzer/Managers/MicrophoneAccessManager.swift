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

    // MARK: - Public

    public func checkAuthorizationStatus() {
        
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        let isAuthorized = status == .authorized
        delegate?.microphoneAccessManager(didChangeAuthorizationStatusTo: status, isAuthorized: isAuthorized)
    }
}

//AVCaptureDevice.authorizationStatus(for: .audio) == .authorized
