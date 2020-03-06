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
    
    /**
     Create a new Generator instance each time we call the function
     as the reference often times leads to crashes. */
    public func giveFeedback() {
        
        DispatchQueue.main.async {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
}
