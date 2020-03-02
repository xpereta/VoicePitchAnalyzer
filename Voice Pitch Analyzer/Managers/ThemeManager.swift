//
//  Theme.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class ThemeManager {
    
    private var isDarkModeEnabled: Bool = false
    
    private var darkModeBackgroundColor: UIColor {
        return UIColor(hex: "061023")
    }
    
    private var lightModeBackgroundColor: UIColor {
        return UIColor(hex: "ffffff")
    }
    
    private var darkModeOutterRecordButtonColor: UIColor {
        return UIColor(hex: "B98FFE")
    }
    
    private var lightModeOutterRecordButtonColor: UIColor {
        return UIColor(hex: "FF79A8")
    }
    
    private var shadowColor: UIColor {
        return UIColor(hex: "000000")
    }
    
    private var darkModeTextColor: UIColor {
        return UIColor(hex: "EFEFEF")
    }
    
    private var lightModeTextColor: UIColor {
        return UIColor(hex: "202020")
    }
    
    private var lightModeTimeColor: UIColor {
        return UIColor(hex: "27406E")
    }
    
    private var darkModeWaveformColor: UIColor {
        return UIColor(hex: "0E1D3A")
    }
    
    private var lightModeWaveformColor: UIColor {
        return UIColor(hex: "FFE8F0")
    }
    
    // MARK: - Public
    
    /**
            
     Used to test dark mode on the simulator.
     Add themeManager.toggleDarkMode(at: self) wherever
     you need/want to test dark mode appearance.
    */
    public func toggleDarkMode(at controller: UIViewController) {
        isDarkModeEnabled = !isDarkModeEnabled
        
        if #available(iOS 13.0, *) {
            controller.overrideUserInterfaceStyle = isDarkModeEnabled ? .dark : .light
        } 
    }
    
    public func getBackgroundColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return lightModeBackgroundColor
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkModeBackgroundColor
            } else {
                return self.lightModeBackgroundColor
            }
        }
    }
    
    public func getInnerRecordButtonColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return lightModeOutterRecordButtonColor
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkModeOutterRecordButtonColor
            } else {
                return self.lightModeOutterRecordButtonColor
            }
        }
    }
    
    public func getTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return lightModeTextColor
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkModeTextColor
            } else {
                return self.lightModeTextColor
            }
        }
    }
    
    public func getTimeTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return lightModeTimeColor
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkModeTextColor
            } else {
                return self.lightModeTimeColor
            }
        }
    }
    
    public func getWaveformColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return lightModeWaveformColor
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.darkModeWaveformColor
            } else {
                return self.lightModeWaveformColor
            }
        }
    }
    
    public func setInnerRecordButtonShadow(to recordButton: UIButton) {
        
        recordButton.layer.applySketchShadow(
            color: shadowColor,
            alpha: 0.22,
            y: 3,
            blur: 14)
    }
    
    public func getCurrentResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {
        
        let pathWidth: CGFloat = 20
        let pathSpacing: CGFloat = 16
        let xPosition = view.frame.width - (pathSpacing + pathWidth)
        return getResultLayer(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
    }
    
    public func getLastResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {
    
        let pathWidth: CGFloat = 20
        let pathSpacing: CGFloat = 16
        let space = pathSpacing + pathWidth
        let xPosition = view.frame.width - (space * 3)
        return getResultLayer(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
    }
    
    // MARK: - Private
    
    public func getResultLayer(min minAverage: Double, max maxAverage: Double, xPosition: CGFloat, on view: UIView) -> CALayer {
        
        let yourmin = (1.0 - minAverage/340)
        let yourmax = (1.0 - maxAverage/340)

        let recordingUpperRange = view.frame.height * CGFloat(yourmin)
        let recordingLowerRange = view.frame.height * CGFloat(yourmax)
        
        let pathWidth: CGFloat = 20
        let pathHeight: CGFloat = recordingUpperRange - recordingLowerRange
        let pathHorizontalPosition: CGFloat = recordingLowerRange
        
        let yourRange = CGRect(
            x: xPosition,
            y: pathHorizontalPosition,
            width: pathWidth,
            height: pathHeight)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = yourRange
        shapeLayer.setBorderColor(getInnerRecordButtonColor(), with: view)
        shapeLayer.setShadowColor(getInnerRecordButtonColor(), with: view)
        shapeLayer.setBackgroundColor(getInnerRecordButtonColor(), with: view)
        shapeLayer.cornerRadius = 8
        
        return shapeLayer
    }
}
