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
    
    private var c7050A5: UIColor {
        return #colorLiteral(red: 0.4392156863, green: 0.3137254902, blue: 0.6470588235, alpha: 1)
    }
    
    private var cFF93B9: UIColor {
        return #colorLiteral(red: 1, green: 0.5764705882, blue: 0.7254901961, alpha: 1)
    }
    
    private var c253657: UIColor {
        return #colorLiteral(red: 0.1450980392, green: 0.2117647059, blue: 0.3411764706, alpha: 1)
    }
    
    private var cFFD0E1: UIColor {
        return #colorLiteral(red: 1, green: 0.8156862745, blue: 0.8823529412, alpha: 1)
    }
    
    private var cFFFFFF: UIColor {
        return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    private var c000000: UIColor {
        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // MARK: - Public
    
    /**
            
     Used to test dark mode on the simulator.
     Add themeManager.toggleDarkMode(at: self) wherever
     you need/want to test dark mode appearance.
     
     @author David Seek
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
    
    public func getShadowColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return cFF93B9
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.c7050A5
            } else {
                return self.cFF93B9
            }
        }
    }
    
    public func getBorderColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return cFFD0E1
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.c253657
            } else {
                return self.cFFD0E1
            }
        }
    }
    
    public func getSubTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return c000000.withAlphaComponent(0.45)
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return self.cFFFFFF.withAlphaComponent(0.45)
            } else {
                return self.c000000.withAlphaComponent(0.45)
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
        
        let xPosition = view.frame.width - (65 + 32)
        let frame = getVerticalResultFrame(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
        return getResultLayer(frame: frame, on: view)
    }
    
    public func getLastResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {
    
        let xPosition = view.frame.width - (147 + 32)
        let frame = getVerticalResultFrame(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
        return getResultLayer(frame: frame, on: view)
    }
    
    public func getHistoryResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {
    
        let frame = getHorizontalResultFrame(min: minAverage, max: maxAverage, on: view)
        return getResultLayer(frame: frame, on: view, radius: 4)
    }
    
    // MARK: - Private
    
    private func getVerticalResultFrame(min minAverage: Double, max maxAverage: Double, xPosition: CGFloat, on view: UIView) -> CGRect {
        
        let yourmin = (1.0 - minAverage/340)
        let yourmax = (1.0 - maxAverage/340)

        let recordingUpperRange = view.frame.height * CGFloat(yourmin)
        let recordingLowerRange = view.frame.height * CGFloat(yourmax)
        
        let width: CGFloat = 32
        let pathHeight: CGFloat = recordingUpperRange - recordingLowerRange
        let pathHorizontalPosition: CGFloat = recordingLowerRange
        
        return CGRect(
            x: xPosition,
            y: pathHorizontalPosition,
            width: width,
            height: pathHeight)
    }
    
    private func getHorizontalResultFrame(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CGRect {
        
        let yourmin = (1.0 - minAverage/340)
        let yourmax = (1.0 - maxAverage/340)

        let recordingUpperRange = view.frame.width * CGFloat(yourmin)
        let recordingLowerRange = view.frame.width * CGFloat(yourmax)
        
        let pathWidth: CGFloat = recordingUpperRange - recordingLowerRange
        let pathXPosition: CGFloat = recordingLowerRange
        
        return CGRect(
            x: pathXPosition,
            y: 0,
            width: pathWidth,
            height: 8)
    }
    
    private func getResultLayer(frame: CGRect, on view: UIView, radius: CGFloat = 16) -> CALayer {
                
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.setBorderColor(getInnerRecordButtonColor(), with: view)
        shapeLayer.setShadowColor(getShadowColor(), with: view)
        shapeLayer.setBackgroundColor(getInnerRecordButtonColor(), with: view)
        shapeLayer.cornerRadius = radius
        
        shapeLayer.applySketchShadow(
            color: getShadowColor(),
            y: 3,
            blur: 14)
        
        return shapeLayer
    }
}
