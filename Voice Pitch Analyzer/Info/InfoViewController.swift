//
//  InfoViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    private let themeManager: ThemeManager
    private let textManager: TextManager
    
    init(themeManager: ThemeManager,
         textManager: TextManager) {
        
        self.themeManager = themeManager
        self.textManager = textManager
        
        super.init(nibName: "InfoViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        
        view.backgroundColor = themeManager.getBackgroundColor()
        let infoText = textManager.getInfoText()
        let textColor = themeManager.getTextColor()
        let buttonColor = themeManager.getInnerRecordButtonColor()
        
        doneButton.setTitleColor(buttonColor, for: .normal)
        textView.attributedText = textManager.getAttributed(text: infoText, color: textColor)
        
        var versionText = textManager.getVersionText()
        versionText = versionText != nil ? versionText : ""
        versionLabel.attributedText = textManager.getAttributed(text: versionText!, color: textColor, centered: true)
        
        var aboutText = textManager.getAboutText()
        aboutText = aboutText != nil ? aboutText : ""
        aboutLabel.attributedText = textManager.getAttributed(text: aboutText!, color: buttonColor, centered: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAboutLabel))
        aboutLabel.isUserInteractionEnabled = true
        aboutLabel.addGestureRecognizer(tap)
    }
    
    @IBAction func didPressDoneButton(_ sender: Any) {
        
        dismiss(animated: true)
    }
    
    @objc func didPressAboutLabel(sender: UITapGestureRecognizer) {
        
        if let url = URL(string: "https://github.com/purrprogramming/voice-pitch-analyzer/") {
            UIApplication.shared.open(url)
        }
    }
}
