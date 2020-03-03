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
import AVFoundation

class HomeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButtonInnerView: UIButton!
    @IBOutlet weak var waveformContainer: UIView!
    
    private let fireStoreManager: FireStoreManager
    private let themeManager: ThemeManager
    private let textManager: TextManager
    private let timeManager: TimeManager
    private let resultCalculator: ResultCalculator
    
    private var recorder: AVAudioRecorder?
    
    private var timer: Timer?
    private var pitchArray: Array<Double> = Array()
    private var link: CADisplayLink?
    
    lazy var pitchEngine: PitchEngine = { [weak self] in
        var config = Config(bufferSize: 4096, estimationStrategy: .yin)
        return PitchEngine(config: config, delegate: self)
    }()
    
    lazy var waveformView: SCSiriWaveformView = { [weak self] in
        
        let frame = CGRect(
            x: 0,
            y: 0,
            width: waveformContainer.frame.width,
            height: waveformContainer.frame.height)
        
        let view = SCSiriWaveformView(frame: frame)

        view.waveColor = themeManager.getWaveformColor()
        view.backgroundColor = .clear
        view.primaryWaveLineWidth = waveformContainer.frame.height - 100
        view.secondaryWaveLineWidth = (waveformContainer.frame.height - 100) / 2
        view.alpha = 0
        self?.waveformContainer.addSubview(view)
        return view
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
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        presentResultController()
//    }
    
    @IBAction func didPressRecordButton(_ sender: Any) {
        
        print("didPressRecordButton")
        FeedbackManager.shared.giveFeedback()
        
        if timer === nil {
            
            startTimer()
            startRecorder()
            
        } else {
            
            stopTimer()
            stopRecorder()
            presentResultController()
        }
    }
    
    @IBAction func didPressHelpButton(_ sender: Any) {
        
        Log.shared.event(.PressHelpButton)
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
        
        Log.shared.event(.RecordStart)
        pitchEngine.start()
        
        setWaveform()
    }
    
    private func stopRecorder() {
        
        removeWaveform { [weak self] in
            
            Log.shared.event(.RecordStop)
            self?.pitchEngine.stop()
            self?.pitchArray = []
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
    
    private func presentResultController() {
        
        let controller = ResultViewController(
            fireStoreManager: fireStoreManager,
            themeManager: themeManager,
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
    
    private func setWaveform() {
            
        do {
                
            let url = URL(fileURLWithPath: "/dev/null")
            recorder = try AVAudioRecorder(url: url, settings: [
                AVSampleRateKey: 44100.0,
                AVFormatIDKey: kAudioFormatAppleLossless,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ])
            
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            
            DispatchQueue.global(qos: .background).async { [weak self] in
                
                guard let self = self, let recorder = self.recorder else {
                    return
                }
                    
                recorder.prepareToRecord()
                recorder.isMeteringEnabled = true
                recorder.record()
                
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.3) { [weak self] in
                        self?.waveformView.alpha = 1
                    }
                }
            }
            
            link = CADisplayLink(target: self, selector: #selector(updateMeters))
            link?.add(to: .current, forMode: .commonModes)
                
        } catch let error {
        
            Log.shared.record(error, at: #function)
        }
    }
    
    private func removeWaveform(completion: @escaping () -> ()) {
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            self?.link?.remove(from: .current, forMode: .commonModes)
            self?.recorder?.isMeteringEnabled = false
            self?.recorder?.stop()
            self?.recorder = nil
            
            DispatchQueue.main.async { [weak self] in
                self?.waveformView.alpha = 0
                completion()
            }
        }
    }
    
    @objc func updateMeters() {
        
        guard let recorder = self.recorder else {
            return
        }
        
        recorder.updateMeters()
        
        let normalizedValue = pow(10, CGFloat(recorder.averagePower(forChannel: 0))/10)
        self.waveformView.update(withLevel: normalizedValue)
    }
}

// MARK: - PitchEngineDelegate
extension HomeViewController: PitchEngineDelegate {
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        if pitch.frequency < 340.0 && pitch.frequency > 65.0 {
            pitchArray.append(pitch.frequency)
        }
    }
    
    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {

        if error.localizedDescription != "The operation couldn’t be completed. (Pitchy.PitchError error 0.)" &&
            error.localizedDescription != "The operation couldn’t be completed. (Pitchy.PitchError error 3.)" {
            
            print("pitchEngine didReceiveError: \(error.localizedDescription)")
            Log.shared.record(error, at: #function)
        }
    }

    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine){
        // intentionally left empty
    }
}
