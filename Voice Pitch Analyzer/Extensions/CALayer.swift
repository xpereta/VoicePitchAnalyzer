//
//  CALayer.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit

extension CALayer {

  func applySketchShadow(
    color: UIColor = .black,
    alpha: Float = 1,
    xPosition: CGFloat = 0,
    yPosition: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0) {

    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: xPosition, height: yPosition)
    shadowRadius = blur / 2.0

    if spread == 0 {
      shadowPath = nil
    } else {

      let calculatedX = -spread
      let rect = bounds.insetBy(dx: calculatedX, dy: calculatedX)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
