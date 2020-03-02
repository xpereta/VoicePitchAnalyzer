//
//  HomeViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 Carola Nitz. All rights reserved.
//

import UIKit
import Beethoven
import Pitchy

class HomeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButtonInnerView: UIButton!
    
    private let fireStoreManager: FireStoreManager
    private let themeManager: ThemeManager
    private let textManager: TextManager
    private let timeManager: TimeManager
    private let resultCalculator: ResultCalculator
    
    private var timer: Timer?
    private var pitchArray: Array<Double> = Array()
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        var config = Config(bufferSize: 4096, estimationStrategy: .yin)
        return PitchEngine(config: config, delegate: self)
    }()
    
    init(fireStoreManager: FireStoreManager,
         themeManager: ThemeManager,
         textManager: TextManager,
         timeManager: TimeManager,
         resultCalculator: ResultCalculator) {
        
        self.fireStoreManager = fireStoreManager
        self.themeManager = themeManager
        self.textManager = textManager
        self.timeManager = timeManager
        self.resultCalculator = resultCalculator
        
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
        
        FeedbackManager.shared.giveFeedback()
        
        if timer === nil {
            
            startTimer()
            startRecorder()
            
        } else {
            
            presentResultController()
            stopTimer()
            stopRecorder()
        }
    }
    
    @IBAction func didPressHelpButton(_ sender: Any) {
        
        presentInfoController()
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        
        view.backgroundColor = themeManager.getBackgroundColor()
        recordButtonInnerView.backgroundColor = themeManager.getInnerRecordButtonColor()
        recordButtonInnerView.layer.cornerRadius = recordButtonInnerView.frame.width / 2
        themeManager.setInnerRecordButtonShadow(to: recordButtonInnerView)
        
        timeLabel.textColor = themeManager.getTimeTextColor()
        timeLabel.text = nil
        
        let recorderText = textManager.getRecorderText()!
        let textColor = themeManager.getTextColor()
        textView.attributedText = textManager.getAttributed(text: recorderText, color: textColor)
        
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
                self.didPressRecordButton(self)
            }
        }
    }
    
    private func startRecorder() {
        
        pitchEngine.start()
    }
    
    private func stopRecorder() {
        
        pitchEngine.stop()
        pitchArray = []
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
    
    private func presentResultController() {
        
        let controller = ResultViewController(
            fireStoreManager: fireStoreManager,
            resultCalculator: resultCalculator,
            pitchArray: pitchArray)
        
        present(controller, animated: true)
    }
    
    private func presentInfoController() {
        
        let controller = InfoViewController(
            themeManager: themeManager,
            textManager: textManager)
        
        present(controller, animated: true)
    }
}

// MARK: - PitchEngineDelegate

extension HomeViewController: PitchEngineDelegate {
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        if pitch.frequency < 340.0 && pitch.frequency > 65.0 {
            pitchArray.append(pitch.frequency)
            print("pitchEngine didReceivePitch: \(pitchArray)")
        }
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print("pitchEngine didReceiveError: \(error.localizedDescription)")
    }

    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine){
        // intentionally left empty
    }
}
