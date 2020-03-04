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
    
    private let recordingManager: RecordingManager
    private let databaseManager: DatabaseManager
    private let themeManager: ThemeManager
    private let textManager: TextManager
    private let resultCalculator: ResultCalculator
    
    private var recorder: AVAudioRecorder?
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

        view.waveColor = ColorCache.shared.getWaveformColor()
        view.backgroundColor = .clear
        view.primaryWaveLineWidth = waveformContainer.frame.height - 100
        view.secondaryWaveLineWidth = (waveformContainer.frame.height - 100) / 2
        view.alpha = 0
        self?.waveformContainer.addSubview(view)
        return view
    }()
    
    init(recordingManager: RecordingManager,
         databaseManager: DatabaseManager,
         themeManager: ThemeManager,
         textManager: TextManager,
         resultCalculator: ResultCalculator) {
        
        self.recordingManager = recordingManager
        self.databaseManager = databaseManager
        self.themeManager = themeManager
        self.textManager = textManager
        self.resultCalculator = resultCalculator
        
        super.init(nibName: "HomeViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordingManager.delegate = self
        setAppearance()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presentResultController {}
    }
    
    @IBAction func didPressRecordButton(_ sender: Any) {
        
        FeedbackManager.shared.giveFeedback()
        recordingManager.toggleRecordingState()
    }
    
    @IBAction func didPressHelpButton(_ sender: Any) {
        
        Log.event(.PressHelpButton)
        presentInfoController()
    }
    
    // MARK: - Private
    
    private func setAppearance() {
        
        view.backgroundColor = ColorCache.shared.getBackgroundColor()
        themeManager.setInnerRecordButtonShadow(to: recordButtonInnerView)
        
        timeLabel.textColor = ColorCache.shared.getTimeTextColor()
        timeLabel.text = nil
        
        let recorderText = textManager.getRecorderText()!
        let textColor = ColorCache.shared.getTextColor()
        textView.attributedText = textManager.getAttributed(text: recorderText, color: textColor)
        
        resetTextView()
    }
    
    private func updateRecordButton(toRecording isRecording: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            if isRecording {
                self?.recordButtonInnerView.setImage(ImageCache.shared.stop, for: .normal)
            } else {
                self?.recordButtonInnerView.setImage(ImageCache.shared.record, for: .normal)
            }
        }
    }
    
    private func startRecorder() {
        
        Log.event(.RecordStart)
        
        DispatchQueue.main.async { [weak self] in
            self?.pitchEngine.start()
            self?.setWaveform()
        }
    }
    
    private func stopRecorder() {
        
        removeWaveform { [weak self] in
            
            Log.event(.RecordStop)
            self?.pitchEngine.stop()
            self?.pitchArray = []
        }
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
    
    private func presentResultController(completion: @escaping () -> ()) {
        
        let controller = ResultViewController(
            databaseManager: databaseManager,
            themeManager: themeManager,
            resultCalculator: resultCalculator,
            pitchArray: pitchArray)
        
        present(controller, animated: true, completion: completion)
    }
    
    private func presentInfoController() {
        
        let controller = InfoViewController(textManager: textManager)
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
                
            recorder?.prepareToRecord()
            recorder?.isMeteringEnabled = true
            recorder?.record()
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.waveformView.alpha = 1
            }
            
            link = CADisplayLink(target: self, selector: #selector(updateMeters))
            link?.add(to: .current, forMode: .commonModes)
                
        } catch let error {
        
            Log.record(error, at: #function)
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
            Log.record(error, at: #function)
        }
    }

    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine){
        // intentionally left empty
    }
}

// MARK: - RecordingManagerDelegate
extension HomeViewController: RecordingManagerDelegate {

    func recordingManager(didUpdateRemainingTime time: String?) {
        
        self.timeLabel.text = time
    }
    
    func recordingManager(didUpdateRecordingState isRecording: Bool) {
        
        if isRecording {
            startRecorder()
            updateRecordButton(toRecording: true)
        } else  {
            stopRecorder()
            
            presentResultController { [weak self] in
                self?.updateRecordButton(toRecording: false)
            }
        }
    }
    
    func recordingManager(didUpdateTimer timerDidStop: Bool) {
        
        if timerDidStop {
            resetTextView()
        } else {
            moveTextView()
        }
    }
}
