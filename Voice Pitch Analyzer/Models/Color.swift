//
//  Color.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/4/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

// MARK: - Color Cache
struct Color {
    
    static private let cFFFFFF = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static private let cEFEFEF = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
    static private let cFFE8F0 = #colorLiteral(red: 1, green: 0.9098039216, blue: 0.9411764706, alpha: 1)
    static private let cFFD0E1 = #colorLiteral(red: 1, green: 0.8156862745, blue: 0.8823529412, alpha: 1)
    static private let cFF93B9 = #colorLiteral(red: 1, green: 0.5764705882, blue: 0.7254901961, alpha: 1)
    static private let cFF79A8 = #colorLiteral(red: 1, green: 0.4745098039, blue: 0.6588235294, alpha: 1)
    static private let cB98FFE = #colorLiteral(red: 0.7254901961, green: 0.5607843137, blue: 0.9960784314, alpha: 1)
    static private let c7050A5 = #colorLiteral(red: 0.4392156863, green: 0.3137254902, blue: 0.6470588235, alpha: 1)
    static private let c27406E = #colorLiteral(red: 0.1529411765, green: 0.2509803922, blue: 0.431372549, alpha: 1)
    static private let c253657 = #colorLiteral(red: 0.1450980392, green: 0.2117647059, blue: 0.3411764706, alpha: 1)
    static private let c0E1D3A = #colorLiteral(red: 0.05490196078, green: 0.1137254902, blue: 0.2274509804, alpha: 1)
    static private let c061023 = #colorLiteral(red: 0.02352941176, green: 0.06274509804, blue: 0.137254902, alpha: 1)
    static private let c000000 = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    static private let c202020 = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    
    static public func getBackgroundColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return cFFFFFF
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return c061023
            } else {
                return cFFFFFF
            }
        }
    }
    
    static public func getInnerRecordButtonColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.cFF79A8
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.cB98FFE
            } else {
                return Color.cFF79A8
            }
        }
    }
    
    static public func getTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.c202020
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.cEFEFEF
            } else {
                return Color.c202020
            }
        }
    }
    
    static public func getTimeTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.c27406E
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.cEFEFEF
            } else {
                return Color.c27406E
            }
        }
    }
    
    static public func getWaveformColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.cFFE8F0
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.c0E1D3A
            } else {
                return Color.cFFE8F0
            }
        }
    }
    
    static public func getShadowColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.cFF93B9
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.c7050A5
            } else {
                return Color.cFF93B9
            }
        }
    }
    
    static public func getBorderColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.cFFD0E1
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.c253657
            } else {
                return Color.cFFD0E1
            }
        }
    }
    
    static public func getSubTextColor() -> UIColor {
        
        guard #available(iOS 13, *) else {
            return Color.c000000.withAlphaComponent(0.45)
        }
        
        return UIColor { (traitCollection: UITraitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .dark {
                return Color.cFFFFFF.withAlphaComponent(0.45)
            } else {
                return Color.c000000.withAlphaComponent(0.45)
            }
        }
    }
}
