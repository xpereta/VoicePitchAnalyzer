//
//  RecordButton.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit

class RecordButton: UIButton {
    
    /** Custom button used in HomeViewController. Removes shadow when clicked. */
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                self.layer.shadowOpacity = self.isHighlighted ? 0 : 0.22
            }
        }
    }
}
