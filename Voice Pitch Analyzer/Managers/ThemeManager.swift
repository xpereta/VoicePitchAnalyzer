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
    
    public func setInnerRecordButtonShadow(to recordButton: UIButton) {
        
        recordButton.layer.applySketchShadow(
            color: ColorCache.shared.getShadowColor(),
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
    
    private func getVerticalResultFrame(
        min minAverage: Double,
        max maxAverage: Double,
        xPosition: CGFloat,
        on view: UIView) -> CGRect {
        
        let userMinimum: CGFloat = CGFloat(minAverage)
        let userMaximum: CGFloat = CGFloat(maxAverage)
        
        //let lowPoint: CGFloat = 85
        let topPoint: CGFloat = 255
        
        let height = (userMaximum - userMinimum) * 2
        let yPosition = (topPoint - userMaximum) * 2
        
        return CGRect(
            x: xPosition,
            y: yPosition,
            width: 32,
            height: height)
    }
    
    private func getHorizontalResultFrame(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CGRect {
        
//        let yourmin = (1.0 - minAverage/340)
//        let yourmax = (1.0 - maxAverage/340)
//
//        let recordingUpperRange = view.frame.width * CGFloat(yourmin)
//        let recordingLowerRange = view.frame.width * CGFloat(yourmax)
//
//        let pathWidth: CGFloat = recordingUpperRange - recordingLowerRange
//        let pathXPosition: CGFloat = recordingLowerRange
        
        let userMinimum: CGFloat = CGFloat(minAverage)
        let userMaximum: CGFloat = CGFloat(maxAverage)
        
        let lowPoint: CGFloat = 85
        //let topPoint: CGFloat = 255
        
        let width = (userMaximum - userMinimum) * 2
        let xPosition = (userMinimum - lowPoint) * 2
        let factor = view.frame.width / 340
        let width_ = width * factor
        let xPosition_ = xPosition * factor
        
        print("userMinimum: \(userMinimum)")
        print("userMaximum: \(userMaximum)")
        print("xPosition_: \(xPosition_)")
        print("view.frame.width: \(view.frame.width)")
        print("width_: \(width_)")
        print("\n")
        
        return CGRect(
            x: xPosition_,
            y: 0,
            width: width_,
            height: 8)
    }
    
    private func getResultLayer(frame: CGRect, on view: UIView, radius: CGFloat = 16) -> CALayer {
                
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.setBorderColor(ColorCache.shared.getInnerRecordButtonColor(), with: view)
        shapeLayer.setShadowColor(ColorCache.shared.getShadowColor(), with: view)
        shapeLayer.setBackgroundColor(ColorCache.shared.getInnerRecordButtonColor(), with: view)
        shapeLayer.cornerRadius = radius
        
        shapeLayer.applySketchShadow(
            color: ColorCache.shared.getShadowColor(),
            y: 3,
            blur: 14)
        
        return shapeLayer
    }
}
