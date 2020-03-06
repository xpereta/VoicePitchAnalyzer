//
//  Image.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/4/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

// MARK: - Image Cache

/** Cache for images. Saves memory. */
struct ImageCache {
    
    public static let shared = ImageCache()
    
    // MARK: - Public

    public let stop = UIImage(named: "stop")
    public let record = UIImage(named: "recordButtonInner")
}
