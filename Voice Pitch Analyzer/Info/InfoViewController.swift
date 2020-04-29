//
//  InfoViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!

    private let textManager: TextManager

    init(textManager: TextManager) {
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
    
    // MARK: - Public
    
    @IBAction func didPressDoneButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @objc func didPressAboutLabel(sender: UITapGestureRecognizer) {

        Log.event(.githubInfo)
        let urlString = "https://github.com/purrprogramming/voice-pitch-analyzer/"
        guard let url = URL(string: urlString) else {
            return
        }

        UIApplication.shared.open(url)
    }

    // MARK: - Private

    private func setAppearance() {

        view.backgroundColor = ColorCache.shared.getBackgroundColor()
        let textColor = ColorCache.shared.getTextColor()
        let buttonColor = ColorCache.shared.getInnerRecordButtonColor()

        doneButton.setTitleColor(buttonColor, for: .normal)
        doneButton.setTitle(textManager.getLocalized(.done), for: .normal)

        if let infoText = textManager.getLocalized(.welcome) {
            textView.attributedText = textManager.getAttributed(text: infoText, color: textColor)
        }

        var versionText = textManager.getVersionText()
        versionText = versionText != nil ? versionText : ""
        versionLabel.attributedText = textManager.getAttributed(text: versionText!, color: textColor, centered: true)

        var aboutText = textManager.getLocalized(.about)
        aboutText = aboutText != nil ? aboutText : ""
        aboutLabel.attributedText = textManager.getAttributed(text: aboutText!, color: buttonColor, centered: true)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAboutLabel))
        aboutLabel.isUserInteractionEnabled = true
        aboutLabel.addGestureRecognizer(tap)
    }
}
