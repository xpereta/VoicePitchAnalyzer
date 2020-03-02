//
//  HomeViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButtonInnerView: UIButton!
    
    private let themeManager: ThemeManager
    private let textManager: TextManager
    private let timeManager: TimeManager
    
    private var timer: Timer?
    
    init(themeManager: ThemeManager,
         textManager: TextManager,
         timeManager: TimeManager) {
        
        self.themeManager = themeManager
        self.textManager = textManager
        self.timeManager = timeManager
        
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
    }
    
    @IBAction func didPressRecordButton(_ sender: Any) {
        
        themeManager.toggleDarkMode(at: self)
        FeedbackManager.shared.giveFeedback()
        
        if timer === nil {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        view.backgroundColor = themeManager.getBackgroundColor()
        recordButtonInnerView.backgroundColor = themeManager.getInnerRecordButtonColor()
        recordButtonInnerView.layer.cornerRadius = recordButtonInnerView.frame.width / 2
        themeManager.setInnerRecordButtonShadow(to: recordButtonInnerView)
        
        timeLabel.textColor = themeManager.getTimeTextColor()
        timeLabel.text = nil
        
        let textColor = themeManager.getTextColor()
        textView.attributedText = textManager.getAttributedText(with: textColor)
        
        resetTextView()
    }
    
    private func startTimer() {
        
        timeLabel.text = textManager.getFormattedRemainingTime()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            
            guard let self = self else { return }
            self.timeLabel.text = self.textManager.getFormattedRemainingTime()
            self.timeManager.reduceTime(by: 0.1)
            self.moveTextView()
            
            if self.timeManager.getRemainingTime() <= 0 {
                self.stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        
        timer?.invalidate()
        timer = nil
        
        timeManager.reduceTime(by: nil)
        timeLabel.text = nil
        resetTextView()
    }
    
    private func resetTextView() {
        
        let initialTextViewOffset: CGFloat = -268
        let point = CGPoint(x: 0.0, y: initialTextViewOffset)
        textView.setContentOffset(point, animated: true)
    }
    
    private func moveTextView() {
        
        let offset = textView.contentOffset.y
        let point = CGPoint(x: 0.0, y: offset + 7)
        textView.setContentOffset(point, animated: true)
    }
}
