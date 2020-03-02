//
//  FeedbackManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class FeedbackManager {
    
    static let shared = FeedbackManager()
    
    // MARK: - Public
    
    public func giveFeedback() {
        
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.selectionChanged()
    }
}
