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
    
    /** Get the localized welcome text for the InfoViewController  */
    public func getInfoText() -> String {
        return NSLocalizedString("Welcome", comment: "")
    }
    
    /** We're crashing the app if the Recorder Text can't be loaded. No point to keep the app alive at this point. */
    public func getRecorderText() -> String? {
        
        do {
            
            var lang = NSLocale.preferredLanguages.first
            let range = ..<lang!.index(lang!.startIndex, offsetBy: 2)
            lang = String(lang![range])
            
            if (lang != "de" && lang != "en" && lang != "it" && lang != "pt") {
                lang = "en"
            }
            
            guard let file = Bundle.main.url(forResource: lang, withExtension: "json") else {
                let error = "Error in TextManager.getText() file not found"
                Log.recordProblem(error, at: #function)
                fatalError(error)
            }
            
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            
            guard let object = json as? [String: Any] else {
                let error = "Error in TextManager.getText() JSON invalid"
                Log.recordProblem(error, at: #function)
                fatalError(error)
            }
            
            guard let texts = object["texts"] as? [String : Any] else {
                let error = "Error in TextManager.getText() JSON empty"
                Log.recordProblem(error, at: #function)
                fatalError(error)
            }
            
            let dict = texts[lang!] as! [String]
            let randomNumber = Int(arc4random() % 457)
            
            guard randomNumber < dict.count else {
                let error = "Error in TextManager.getText() dict empty"
                Log.recordProblem(error, at: #function)
                fatalError(error)
            }
            
            return dict[randomNumber]
            
        } catch let error {

            Log.record(error, at: #function)
            fatalError(error.localizedDescription)
        }
    }
    
    /** Get version and build number for the InfoViewController */
    public func getVersionText() -> String? {
        
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            return nil
        }
        
        return "v \(version) \(build)"
    }
    
    /** Get the localized about text for the InfoViewController  */
    public func getAboutText() -> String? {
        return NSLocalizedString("BasedOn", comment:"")
    }
}
