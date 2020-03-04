//
//  TextManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class TextManager {
    
    // MARK: - Public
    
    public func getAttributed(text: String, color textColor: UIColor, centered: Bool = false) -> NSAttributedString {
        
        let sketchLineHeight: CGFloat = 38
        let font = UIFont.systemFont(ofSize: 21)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = sketchLineHeight - font.lineHeight
        
        if centered {
            style.alignment = .center
        }
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle : style,
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: textColor
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    public func getInfoText() -> String {
        return NSLocalizedString("Welcome", comment: "")
    }
    
    public func getRecorderText() -> String? {
        
        do {
            
            var lang = NSLocale.preferredLanguages.first
            let range = ..<lang!.index(lang!.startIndex, offsetBy: 2)
            lang = String(lang![range])
            
            if (lang != "de" && lang != "en" && lang != "it" && lang != "pt") {
                lang = "en"
            }
            
            guard let file = Bundle.main.url(forResource: lang, withExtension: "json") else {
                print("Error in TextManager.getText() file not found")
                return nil
            }
            
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let object = json as? [String: Any] else {
                print("Error in TextManager.getText() JSON invalid")
                return nil
            }
            
            guard let texts = object["texts"] as? [String : Any] else {
                print("Error in TextManager.getText() JSON empty")
                return nil
            }
            
            let dict = texts[lang!] as! [String]
            let randomNumber = Int(arc4random() % 457)
            
            guard randomNumber < dict.count else {
                print("Error in TextManager.getText() dict empty")
                return nil
            }
            
            return dict[randomNumber]
            
        } catch let error {
            
            print("Error in TextManager.getText() \(error.localizedDescription)")
            return nil
        }
    }
    
    public func getVersionText() -> String? {
        
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return nil
        }
        
        return "v \(version) \(build)"
    }
    
    public func getAboutText() -> String? {
        return NSLocalizedString("BasedOn", comment:"")
    }
}
