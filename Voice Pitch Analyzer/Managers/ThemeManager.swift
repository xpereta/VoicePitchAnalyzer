//
//  Theme.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
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

    /** Applies the Sketch shadow to the record button */
    public func setInnerRecordButtonShadow(to recordButton: UIButton) {

        recordButton.layer.applySketchShadow(
            color: ColorCache.shared.getShadowColor(),
            alpha: 0.22,
            yPosition: 3,
            blur: 14)
    }

    public func getCurrentResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {

        /** Current result layer is on the right hand side */
        let xPosition = view.frame.width - (65 + 32)
        let frame = getVerticalResultFrame(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
        return getResultLayer(frame: frame, on: view, isHistoryLayer: false)
    }

    public func getLastResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {

        /** Last result layer is on the left hand side */
        let xPosition = view.frame.width - (147 + 32)
        let frame = getVerticalResultFrame(min: minAverage, max: maxAverage, xPosition: xPosition, on: view)
        return getResultLayer(frame: frame, on: view, isHistoryLayer: false)
    }

    public func getHistoryResultLayer(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CALayer {

        /** Horizontally aligned result history */
        let frame = getHorizontalResultFrame(min: minAverage, max: maxAverage, on: view)
        return getResultLayer(frame: frame, on: view, isHistoryLayer: true)
    }

    // MARK: - Private

    private func getVerticalResultFrame(
        min minAverage: Double,
        max maxAverage: Double,
        xPosition: CGFloat,
        on view: UIView) -> CGRect {

        let userMinimum: CGFloat = CGFloat(minAverage)
        let userMaximum: CGFloat = CGFloat(maxAverage)

        /** 255 is the maximum supported averga Hz level*/
        let topPoint: CGFloat = 255

        /** Maximum - minumum times 2 equals the height of the layer in pts*/
        let height = (userMaximum - userMinimum) * 2

        /**
         The Y position of the layer is based on the topLevel and the maximum of 255 Hz times 2
         Examples:
         255Hz = 0 pts
         200Hz = 110 pts */
        let yPosition = (topPoint - userMaximum) * 2

        return CGRect(
            x: xPosition,
            y: yPosition,
            width: 32,
            height: height)
    }

    private func getHorizontalResultFrame(min minAverage: Double, max maxAverage: Double, on view: UIView) -> CGRect {

        let userMinimum: CGFloat = CGFloat(minAverage)
        let userMaximum: CGFloat = CGFloat(maxAverage)

        /** In the horizontal presentation, we start the calculation form the mimum frequenzy of 85 Hz*/
        let lowPoint: CGFloat = 85

        /** The width equals the maximum and minimum times 2*/
        let width = (userMaximum - userMinimum) * 2
        let xPosition = (userMinimum - lowPoint) * 2

        /**
         We need the factor as oppose to the vertical view where the height is always 340 pts,
         the width varies based on the screen size */
        let factor = view.frame.width / 340
        let calculatedWidth = width * factor
        let calculatedxPosition = xPosition * factor

        return CGRect(
            x: calculatedxPosition,
            y: 0,
            width: calculatedWidth,
            height: 8)
    }

    /**
     
        Returns a layer to display a result
     
     - parameters:
        - frame: CGRect of the layer
        - view: UIView the layer will be presented on (used to set theming color for dark mode support of iOS below 13)
        - redius: Border radius of the layer
        - isHistoryLayer: Used to determine if the middle is marked vertically or horizontally
     */
    private func getResultLayer(frame: CGRect, on view: UIView, isHistoryLayer: Bool) -> CALayer {

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame

        /** Set colors in this way to obey to dark mode switch AND iOS10 as minimum target*/
        shapeLayer.setBorderColor(ColorCache.shared.getInnerRecordButtonColor(), with: view)
        shapeLayer.setShadowColor(ColorCache.shared.getShadowColor(), with: view)
        shapeLayer.setBackgroundColor(ColorCache.shared.getInnerRecordButtonColor(), with: view)
        shapeLayer.cornerRadius = isHistoryLayer ? 4 : 16

        shapeLayer.applySketchShadow(
            color: ColorCache.shared.getShadowColor(),
            yPosition: 3,
            blur: 14)

        let thickness: CGFloat = 4

        // half width of parent minus half width of self
        let xPosition = isHistoryLayer ? (frame.width / 2 - thickness / 2) : 0

        // half height of parent minus half height of self
        let yPosition = isHistoryLayer ? 0 : (frame.height / 2 - thickness / 2)

        let centerFrame = CGRect(
            x: xPosition,
            y: yPosition,
            width: isHistoryLayer ? 5 : frame.width,
            height: isHistoryLayer ? frame.height : thickness)
        let centerLayer = getCenterLayer(frame: centerFrame, on: view)
        shapeLayer.addSublayer(centerLayer)

        return shapeLayer
    }

    private func getCenterLayer(frame: CGRect, on view: UIView) -> CALayer {

        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = frame
        shapeLayer.setBackgroundColor(ColorCache.shared.getAccentColor(), with: view)
        return shapeLayer
    }
}
