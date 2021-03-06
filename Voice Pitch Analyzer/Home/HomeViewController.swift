//
//  HomeViewController.swift
//  Voice Pitch Analyzer
//
//  Created by David Seek on 3/1/20.
//  Copyright © 2020 David Seek. All rights reserved.
//

import UIKit
import AVFoundation
import Beethoven
import Pitchy

class HomeViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var recordButtonInnerView: UIButton!
    @IBOutlet weak var waveformContainer: UIView!
    @IBOutlet weak var micAccessView: UIView!
    @IBOutlet weak var micAccessLabel: UILabel!
    @IBOutlet weak var micAccessButton: UIButton!

    private let recordingManager: RecordingManager
    private let databaseManager: DatabaseManager
    private let themeManager: ThemeManager
    private let textManager: TextManager
    private let resultCalculator: ResultCalculator
    private let microphoneAccessManager: MicrophoneAccessManager
    private let appleLoginManager: AppleLoginManager

    private var pitchArray: [Double] = Array()
    private var link: CADisplayLink?
    private var lastFrequency: Double?

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
         resultCalculator: ResultCalculator,
         microphoneAccessManager: MicrophoneAccessManager,
         appleLoginManager: AppleLoginManager) {

        self.recordingManager = recordingManager
        self.databaseManager = databaseManager
        self.themeManager = themeManager
        self.textManager = textManager
        self.resultCalculator = resultCalculator
        self.microphoneAccessManager = microphoneAccessManager
        self.appleLoginManager = appleLoginManager

        super.init(nibName: "HomeViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        recordingManager.delegate = self
        microphoneAccessManager.delegate = self

        setAppearance()
        setMicAccessLabel(to: .micAccessExplanation)
        setMicAccessButton(to: .next)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        microphoneAccessManager.checkAuthorizationStatus()
    }

    @IBAction func didPressRecordButton(_ sender: Any) {

        FeedbackManager.shared.giveFeedback()
        recordingManager.toggleRecordingState()
    }

    @IBAction func didPressHelpButton(_ sender: Any) {

        Log.event(.pressHelpButton)
        presentInfoController()
    }

    @IBAction func didPressMicAccessButton(_ sender: Any) {
        microphoneAccessManager.requestAuthorization()
    }

    @IBAction func didPressUserLoginButton(_ sender: Any) {

        Log.event(.userLoginButton)
        presentLoginController()
    }

    // MARK: - Private

    private func setAppearance() {

        view.backgroundColor = ColorCache.shared.getBackgroundColor()
        themeManager.setInnerRecordButtonShadow(to: recordButtonInnerView)

        timeLabel.textColor = ColorCache.shared.getTimeTextColor()

        let recorderText = textManager.getRecorderText()!
        let textColor = ColorCache.shared.getTextColor()
        textView.attributedText = textManager.getAttributed(text: recorderText, color: textColor)

        resetTextView()
    }

    /** Update the image of the record button from a circle to a square */
    private func updateRecordButton(toRecording isRecording: Bool) {

        DispatchQueue.main.async { [weak self] in
            if isRecording {
                self?.recordButtonInnerView.setImage(ImageCache.shared.stop, for: .normal)
            } else {
                self?.recordButtonInnerView.setImage(ImageCache.shared.record, for: .normal)
            }
        }
    }

    private func startPitchEngine() {

        Log.event(.recordStart)

        DispatchQueue.main.async { [weak self] in
            #if targetEnvironment(simulator)
            print("Mic and pitch detection only works on a device.")
            #else
            self?.pitchEngine.start()
            #endif
            self?.setWaveform()
        }
    }

    private func stopPitchEngine() {

       #if targetEnvironment(simulator)
       self.pitchArray = generateSimulatorPitchData()
       #endif

       removeWaveform { [weak self] in

           Log.event(.recordStop)
           #if targetEnvironment(simulator)
           print("Mic and pitch detection only works on a device.")
           #else
           self?.pitchEngine.stop()
           #endif

           self?.pitchArray = []
        }
    }

    /** Reset the textView to its original offset */
    private func resetTextView() {

        let initialTextViewOffset: CGFloat = -268
        let point = CGPoint(x: 0.0, y: initialTextViewOffset)
        textView.setContentOffset(point, animated: true)
    }

    /** Scroll the textView by 7pts per 0.1 seconds. The full text will take roughly 1 minute */
    private func moveTextView() {

        let offset = textView.contentOffset.y

        /** Moving 7pts per 0.1 seconds. That seems to be the sweet spot to read the snippet in 1 minute. */
        let point = CGPoint(x: 0.0, y: offset + 7)
        textView.setContentOffset(point, animated: true)
    }

    private func presentResultController(completion: @escaping () -> Void) {

        let controller = ResultViewController(
            databaseManager: databaseManager,
            themeManager: themeManager,
            resultCalculator: resultCalculator,
            textManager: textManager,
            pitchArray: pitchArray)

        present(controller, animated: true, completion: completion)
    }

    private func presentInfoController() {

        let controller = InfoViewController(textManager: textManager)
        present(controller, animated: true)
    }

    private func presentLoginController() {

        let controller = LoginViewController(
            textManager: textManager,
            appleLoginManager: appleLoginManager
        )

        present(controller, animated: true)
    }

    /** Present the waveform around the record button and start the recorder */
    private func setWaveform() {

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.waveformView.alpha = 1
        }

        /** Link to update the waveform around the button */
        link = CADisplayLink(target: self, selector: #selector(updateMeters))
        link?.add(to: .current, forMode: RunLoop.Mode.common)
    }

    /** Stop the recorder and hide the waveform */
    private func removeWaveform(completion: @escaping () -> Void) {

        /** Remove the link to stop the waveform setting selector */
        link?.remove(from: .current, forMode: RunLoop.Mode.common)

        DispatchQueue.main.async { [weak self] in
            self?.waveformView.alpha = 0
            completion()
        }
    }

    /** Update waveform coming from  CADisplayLink based on the microphone recorder */
    @objc func updateMeters() {

        if let lastFrequency = lastFrequency {
            let normalizedValue =  pow(10, CGFloat(lastFrequency / 10000)) - 1
            self.waveformView.update(withLevel: normalizedValue)
        }
    }

    private func setMicAccessLabel(to text: Text) {

        DispatchQueue.main.async { [weak self] in

            guard let strongSelf = self else { return }
            let localized = strongSelf.textManager.getLocalized(text)!
            let textColor = ColorCache.shared.getTextColor()
            strongSelf.micAccessLabel.attributedText = strongSelf.textManager.getAttributed(text: localized, color: textColor)
        }
    }

    private func setMicAccessButton(to text: Text) {

        DispatchQueue.main.async { [weak self] in

            guard let strongSelf = self else { return }
            let localized = strongSelf.textManager.getLocalized(text)!
            let textColor = ColorCache.shared.getBackgroundColor()
            strongSelf.micAccessButton.setTitle(localized, for: .normal)
            strongSelf.micAccessButton.setTitleColor(textColor, for: .normal)
            strongSelf.micAccessButton.backgroundColor = ColorCache.shared.getInnerRecordButtonColor()
            strongSelf.micAccessButton.layer.cornerRadius = 8
        }
    }
}

// MARK: - PitchEngineDelegate
extension HomeViewController: PitchEngineDelegate {

    func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {

        /** Append frequencies above and below the desired levels of 255 and 85 to receive more accurate avergaes */
        if pitch.frequency < 340.0 && pitch.frequency > 65.0 {
            lastFrequency = pitch.wave.frequency
            pitchArray.append(pitch.frequency)
        }
    }

    func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {

        /** Error 0 and 3 seem to be volume kind of pitch recognition errors. No point in loggint those */
        if error.localizedDescription != "The operation couldn’t be completed. (Pitchy.PitchError error 0.)" &&
            error.localizedDescription != "The operation couldn’t be completed. (Pitchy.PitchError error 3.)" {

            print("pitchEngine didReceiveError: \(error.localizedDescription)")
            Log.record(error, at: #function)
        }
    }

    func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        // intentionally left empty
    }
}

// MARK: - RecordingManagerDelegate
extension HomeViewController: RecordingManagerDelegate {

    func recordingManager(didUpdateRemainingTime time: String?) {

        timeLabel.text = time
    }

    func recordingManager(didUpdateRecordingState isRecording: Bool) {

        if isRecording {
            startPitchEngine()
            updateRecordButton(toRecording: true)
        } else {
            stopPitchEngine()

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

    func recordingManager(didReceiveSimulatedPitch pitch: Double) {

        /**
         Simulation of:
         pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch)
         */
        lastFrequency = pitch
    }
}

// MARK: - MicrophoneAccessManagerDelegate
extension HomeViewController: MicrophoneAccessManagerDelegate {

    func microphoneAccessManager(didChangeAuthorizationStatusTo status: AVAuthorizationStatus, isAuthorized: Bool) {

        print("didChangeAuthorizationStatusTo \(status) isAuthorized: \(isAuthorized)")

        if status == .denied {
            setMicAccessLabel(to: .micAccessExplanationDenied)
            setMicAccessButton(to: .openSettings)
        }

        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.micAccessView.alpha = isAuthorized ? 0 : 1
            }
        }
    }
}

// MARK: Simulator support
#if targetEnvironment(simulator)
extension HomeViewController {
    func generateSimulatorPitchData() -> [Double] {
        let numSamples = 10
        let centerPitch = Double.random(in: 100 ... 250)
        let amplitude = Double.random(in: 50 ... 100)
        let lowerPitch = Double(centerPitch - amplitude / 2)
        let highestPitch = Double(centerPitch + amplitude / 2)
        return (0 ..< numSamples).map { _ in Double.random(in: lowerPitch ... highestPitch)}
    }
}
#endif
