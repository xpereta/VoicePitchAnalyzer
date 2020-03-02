//
//  TextManager.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class TextManager {
    
    private let timeManager: TimeManager
    
    init(timeManager: TimeManager) {
        self.timeManager = timeManager
    }
    
    // MARK: - Public
    
    public func getFormattedRemainingTime() -> String {
        
        let time = timeManager.getRemainingTime()
        
        if time == 60 {
            return "01:00"
        }
        
        if time < 10 {
            return "00:0\(time)"
        }
        
        return "00:\(time)"
    }
    
    public func getAttributedText(with textColor: UIColor) -> NSAttributedString {
        
        let sketchLineHeight: CGFloat = 38
        let font = UIFont.systemFont(ofSize: 21)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = sketchLineHeight - font.lineHeight
        
        let attributes = [
            NSAttributedStringKey.paragraphStyle : style,
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.foregroundColor: textColor
        ]
        
        return NSAttributedString(string: getText()!, attributes: attributes)
    }
    
    // MARK: - Private
    
    private func getText() -> String? {
        
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
}
