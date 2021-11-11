//
//  JamViewController.swift
//  JamWith
//
//  Created by Andrew Donnelly on 20/07/2018.
//  Copyright © 2018 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit
import MediaPlayer
import FirebaseAnalytics

class JamViewController: BasePlaybackViewController {

    var drumLoop: DrumLoop!
    let model = JamViewModel()
    var effectsScroller: UIScrollView!

    var instumentView: InstrumentPlayView!

    var loopCounter = 0

    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var rwdButton: UIButton!
    @IBOutlet weak var ffwdButton: UIButton!

    var seconds: Int = 0
    var musicPaused: Bool = false
    var isRecording: Bool = false

    var sixteethPlayer = AVAudioPlayerNode()
    var eightPlayer = AVAudioPlayerNode()
    var quarterPlayer = AVAudioPlayerNode()
    var kitPlayer = AVAudioPlayerNode()
    var trackPlayer = AVAudioPlayerNode()
    var pickedAudioPlayer = AVAudioPlayerNode()

    var sixteenthPCMBuffer: AVAudioPCMBuffer?

    var eightPCMBuffer: AVAudioPCMBuffer?
    var drumsFrameCount: UInt32?

    var quaterPCMBuffer: AVAudioPCMBuffer?
    var clickFrameCount: UInt32?

    var kitPCMBuffer: AVAudioPCMBuffer?
    var tambFrameCount: UInt32?

    var trackPCMBuffer: AVAudioPCMBuffer?
    var shuffleFrameCount: UInt32?

    var micInputNode: AVAudioNode!
    var isMicOpen: Bool = false
    let bus = 0

    var mixerOutputFileURL: String!
    var mixerOutputFile: AVAudioFile!

    var updater: CADisplayLink?
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = sixteethPlayer.lastRenderTime,
            let playerTime = sixteethPlayer.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        return playerTime.sampleTime
    }
    var currentPosition: AVAudioFramePosition = 0

    var sixteethAudioFile: AVAudioFile? {
        didSet {
            if let musicAudioFile = sixteethAudioFile {
                audioLengthSamples = musicAudioFile.length
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate

                audioFormat = musicAudioFile.processingFormat
                musicFrameCount = UInt32(musicAudioFile.length)
                sixteenthPCMBuffer = AVAudioPCMBuffer(pcmFormat: musicAudioFile.processingFormat, frameCapacity: musicFrameCount!)
            }
        }
    }
    var eightAudioFile: AVAudioFile? {
        didSet {
            if let drumsAudioFile = eightAudioFile {
                audioFormat = drumsAudioFile.processingFormat
                drumsFrameCount = UInt32(drumsAudioFile.length)
                eightPCMBuffer = AVAudioPCMBuffer(pcmFormat: drumsAudioFile.processingFormat, frameCapacity: drumsFrameCount!)
            }
        }
    }
    var quarterAudioFile: AVAudioFile? {
        didSet {
            if let clickAudioFile = quarterAudioFile {
                audioFormat = clickAudioFile.processingFormat
                clickFrameCount = UInt32(clickAudioFile.length)
                quaterPCMBuffer = AVAudioPCMBuffer(pcmFormat: clickAudioFile.processingFormat, frameCapacity: clickFrameCount!)
            }
        }
    }
    var kitAudioFile: AVAudioFile? {
        didSet {
            if let tambAudioFile = kitAudioFile {
                audioFormat = tambAudioFile.processingFormat
                tambFrameCount = UInt32(tambAudioFile.length)
                kitPCMBuffer = AVAudioPCMBuffer(pcmFormat: tambAudioFile.processingFormat, frameCapacity: tambFrameCount!)
            }
        }
    }
    var trackAudioFile: AVAudioFile? {
        didSet {
            if let shuffleAudioFile = trackAudioFile {
                audioFormat = shuffleAudioFile.processingFormat
                shuffleFrameCount = UInt32(shuffleAudioFile.length)
                trackPCMBuffer = AVAudioPCMBuffer(pcmFormat: shuffleAudioFile.processingFormat, frameCapacity: shuffleFrameCount!)
            }
        }
    }
    var sixteenthAudioFileURL: URL? {
        didSet {
            if let musicAudioFileURL = sixteenthAudioFileURL {
                sixteethAudioFile = try? AVAudioFile(forReading: musicAudioFileURL)
            }
        }
    }
    var eightAudioURL: URL? {
        didSet {
            if let drumsAudioFileURL = eightAudioURL {
                eightAudioFile = try? AVAudioFile(forReading: drumsAudioFileURL)
            }
        }
    }
    var quaterAudioURL: URL? {
        didSet {
            if let clickAudioFileURL = quaterAudioURL {
                quarterAudioFile = try? AVAudioFile(forReading: clickAudioFileURL)
            }
        }
    }
    var kitAudioFileURL: URL? {
        didSet {
            if let tambAudioFileURL = kitAudioFileURL {
                kitAudioFile = try? AVAudioFile(forReading: tambAudioFileURL)
            }
        }
    }
    var trackAudioFileURL: URL? {
        didSet {
            if let shuffleAudioFileURL = trackAudioFileURL {
                trackAudioFile = try? AVAudioFile(forReading: shuffleAudioFileURL)
            }
        }
    }
    var audioBuffer: AVAudioPCMBuffer?

    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(image: UIImage(named: "Drum-EdLogoMed"))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture_full")!)
        setUpAudioSessionForPlayback()
        setupAudioEngine()
        setUpNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showSwipeMessage()
        Analytics.logEvent("play_loop", parameters: [
            "loopname": drumLoop.LoopName as NSObject
          ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        if timer != nil {
            timer.invalidate()
        }
        if self.isMovingFromParent {
            if engine.isRunning {
                engine.stop()
            }
        }
        tearDownEngine()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        model.layoutViews(view: self.view)
        if model.playButton != nil {
            playButton = model.playButton
            recordButton = model.recButton
            micButton = model.micButton
            effectsScroller = model.effectsScroller
            playButton.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
            recordButton.addTarget(self, action: #selector(recordTapped(_:)), for: .touchUpInside)
            micButton.addTarget(self, action: #selector(openMicTapped(_:)), for: .touchUpInside)
            model.updateViewForNewDrumLoop(loop: drumLoop)
            model.slider.addTarget(self, action: #selector(scrubSliderChanged(_:)), for: .valueChanged)
            model.slider.maximumValue = Float((Double(AVAudioFrameCount(sixteethAudioFile!.length)) / 44100))
        }
    }

    func setUpNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name:AVAudioSession.routeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleSessionInteruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)

        // Instruments Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(sixteenthSliderChanged(_:)), name: Notification.Name(rawValue: kSixteethSliderChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eigthtSliderChanged(_:)), name: Notification.Name(rawValue: kEightSliderChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(quaterSliderChanged(_:)), name: Notification.Name(rawValue: kQuarterValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kitSliderChanged(_:)), name: Notification.Name(rawValue: kKitSliderChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(trackSliderChanged(_:)), name: Notification.Name(rawValue: kTrackValueChanged), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(rateSliderChanged(_:)), name: Notification.Name(rawValue: kSpeedValueChanged), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(mixChanged(_:)), name: Notification.Name(rawValue: kMixValueChanged), object: nil)


        // EQ Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(band0Value(_:)), name: Notification.Name(rawValue: kEQBand0ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band1Value(_:)), name:  Notification.Name(rawValue: kEQBand1ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band2Value(_:)), name: Notification.Name(rawValue: kEQBand2ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band3Value(_:)), name:  Notification.Name(rawValue: kEQBand3ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band4Value(_:)), name:  Notification.Name(rawValue: kEQBand4ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band5Value(_:)), name:  Notification.Name(rawValue: kEQBand5ValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(band6Value(_:)), name:  Notification.Name(rawValue: kEQBand6ValueChanged), object: nil)

        // Reverb Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(reverbMixValue(_:)), name:  Notification.Name(rawValue: kReverbWetDryValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reverbPresetSelected(_:)), name:  Notification.Name(rawValue: kReverbPresetChanged), object: nil)

        // Distortion Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(distortionWetDryMixValue(_:)), name: Notification.Name(rawValue: kDistortionWetDryValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(distortionGainMixValue(_:)), name:  Notification.Name(rawValue: kDistortionGainValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(distortionPresetChangedValue(_:)), name: Notification.Name(rawValue: kDistortionPresetChanged), object: nil)

        // Delay Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(delayTimeValue(_:)), name:  Notification.Name(rawValue: kDelayValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayFeedbackValue(_:)), name: Notification.Name(rawValue: kFeedbackValueChanged), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(delayWetDryMixValue(_:)), name:  Notification.Name(rawValue: kDelayWetDryValueChanged), object: nil)

        // Background notifications
        NotificationCenter.default.addObserver(self, selector: #selector(applicationBackground), name:  UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationActive), name:  UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func handleSessionInteruption(_ notification: Notification) {
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSession.InterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey]! ?? "No key")
                return }
        switch interruptionType {
        case .began:
            if sixteethPlayer.isPlaying {
                pausePlayback()
                playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
            }
//            do {
//                print("setting audiosession to inactive")
//                try audioSession.setActive(false)
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
//        case .ended:
//            do {
//                print("setting audiosession back to active")
//                try audioSession.setActive(true)
//            } catch let error as NSError {
//                print(error.localizedDescription)
//            }
        default :
            if let optionValue = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSession.InterruptionOptions(rawValue: optionValue) == .shouldResume {
                do {
                    try audioSession.setActive(true)
                    startPlayback()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }

    @objc func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonRaw.uintValue)
            else { fatalError("Strange... could not get routeChange") }
        switch reason {
        case .oldDeviceUnavailable:
            if !AVAudioSession.isHeadphonesConnected {
                DispatchQueue.main.async {
                    self.showHeadphoneMessage()
                }
            }
        case .newDeviceAvailable:
            if !AVAudioSession.isHeadphonesConnected {
                DispatchQueue.main.async {
                    self.showHeadphoneMessage()
                }
            }
        case .routeConfigurationChange:
            break
        case .categoryChange:
            break
        default:
            break
        }
    }

    @objc func applicationBackground() {
//        if engine.isRunning && !sixteethPlayer.isPlaying && !isRecording && !isMicOpen {
//            timer.invalidate()
//            engine.stop()
//        }
    }

    @objc func applicationActive() {
//        if !engine.isRunning {
//            prepareAndStartEngine()
//        }
    }

    func setupAudioEngine() {
        if downloadHelper.haveTheFilesBeenDownloaded(drumLoop: drumLoop) {
            sixteenthAudioFileURL = getDocumentsDirectory().appendingPathComponent(drumLoop.Files[0])
            eightAudioURL  =  getDocumentsDirectory().appendingPathComponent(drumLoop.Files[1])
            quaterAudioURL  =  getDocumentsDirectory().appendingPathComponent(drumLoop.Files[2])
            kitAudioFileURL  =  getDocumentsDirectory().appendingPathComponent(drumLoop.Files[3])
            trackAudioFileURL  =  getDocumentsDirectory().appendingPathComponent(drumLoop.Files[4])
        } else {
            sixteenthAudioFileURL = Bundle.main.url(forResource: drumLoop.Files[0], withExtension: "")
            eightAudioURL  =  Bundle.main.url(forResource: drumLoop.Files[1], withExtension: "")
            quaterAudioURL  =  Bundle.main.url(forResource: drumLoop.Files[2], withExtension: "")
            kitAudioFileURL  =  Bundle.main.url(forResource: drumLoop.Files[3], withExtension: "")
            trackAudioFileURL  =  Bundle.main.url(forResource: drumLoop.Files[4], withExtension: "")
        }

        reverb.loadFactoryPreset(.smallRoom)
        reverb.wetDryMix = 0

        equalizer = AVAudioUnitEQ(numberOfBands: 7)
        equalizer.globalGain = 15.0
        let bands = equalizer.bands
        let freqs = [60, 100, 200, 400, 1000, 3000, 10000,]
        for i in 0...(bands.count - 1) {
            bands[i].frequency  = Float(freqs[i])
            bands[i].bypass     = false
            bands[i].filterType = .parametric
        }

        delay.delayTime = 0
        delay.feedback = 0
        delay.lowPassCutoff = 15000
        delay.wetDryMix = 0

        distortion.loadFactoryPreset(.drumsBitBrush)
        distortion.preGain = -80
        distortion.wetDryMix = 0

        playMixer.outputVolume = 1.0

        connectNodes()

        guard let sixteethAudioFile = sixteethAudioFile else { return }
        guard let eightAudioFile = eightAudioFile else { return }
        guard let quarterAudioFile = quarterAudioFile else { return }
        guard let kitAudioFile = kitAudioFile else { return }
        guard let trackAudioFile = trackAudioFile else { return }

        do {
            try sixteethAudioFile.read(into: sixteenthPCMBuffer!)
            sixteethPlayer.scheduleBuffer(sixteenthPCMBuffer!, at: nil, options:.loops, completionHandler: nil)
            sixteethPlayer.volume = 1.0

            try eightAudioFile.read(into: eightPCMBuffer!)
            eightPlayer.scheduleBuffer(eightPCMBuffer!, at: nil, options:.loops, completionHandler: nil)
            eightPlayer.volume = 1.0

            try quarterAudioFile.read(into: quaterPCMBuffer!)
            quarterPlayer.scheduleBuffer(quaterPCMBuffer!, at: nil, options:.loops, completionHandler: nil)
            quarterPlayer.volume = 1.0

            try kitAudioFile.read(into: kitPCMBuffer!)
            kitPlayer.scheduleBuffer(kitPCMBuffer!, at: nil, options:.loops, completionHandler: nil)
            kitPlayer.volume = 1.0

            try trackAudioFile.read(into: trackPCMBuffer!)
            trackPlayer.scheduleBuffer(trackPCMBuffer!, at: nil, options:.loops, completionHandler: nil)
            trackPlayer.volume = 1.0

            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateViewForPlayerInfo), userInfo: nil, repeats: true)

            let audioNodeFileLength = AVAudioFrameCount(sixteethAudioFile.length)
            print("TRACK DURATION \(Double(Double(audioNodeFileLength) / 44100).formattedTimeString() )") //Divide by the AVSampleRateKey in the recorder settings
        } catch let error {
            print(error.localizedDescription)
        }
    }

    @objc func scrubSliderChanged(_ sender: UISlider) {
        print("SLIDER CHANGED \(sender.value)")
        if sixteethPlayer.isPlaying {
            let audioNodeFileLength = AVAudioFrameCount(sixteethAudioFile!.length)
            let duration = Float((Double(audioNodeFileLength) / 44100))
            let startSampleTime = AVAudioFramePosition(Double(sixteethPlayer.lastRenderTime!.sampleTime) + Double(sender.value) * Double(44100))
            let scrubTime = AVAudioTime(sampleTime: startSampleTime, atRate: Double(44100))

            print("SENDER \(sender.value) DURATION \(duration)")
            sixteethPlayer.seekTo(value: sender.value, audioFile: sixteethAudioFile!, duration: duration)
            eightPlayer.seekTo(value: sender.value, audioFile: eightAudioFile!, duration: duration)
            quarterPlayer.seekTo(value: sender.value, audioFile: quarterAudioFile!, duration: duration)
            kitPlayer.seekTo(value: sender.value, audioFile: kitAudioFile!, duration: duration)
            trackPlayer.seekTo(value: sender.value, audioFile: trackAudioFile!, duration: duration)
        }
    }

    func currentTimeInSeconds() -> TimeInterval
    {
        guard let nodeTime = sixteethPlayer.lastRenderTime else { return TimeInterval(0) }
        if let playerTime = sixteethPlayer.playerTime(forNodeTime: nodeTime) {
            let seconds = Double(playerTime.sampleTime) / playerTime.sampleRate
            return seconds
        } else { return TimeInterval(0)}
    }

    func connectNodes() {
        inputMixer.outputVolume = 0.5

        micInputNode = engine.inputNode
        engine.attach(sixteethPlayer)
        engine.attach(eightPlayer)
        engine.attach(quarterPlayer)
        engine.attach(kitPlayer)
        engine.attach(trackPlayer)
        engine.attach(rateEffect)
        engine.attach(reverb)
        engine.attach(playMixer)
        engine.attach(effectMixer)
        engine.attach(inputMixer)
        engine.attach(recordingMixer)
        engine.attach(equalizer)
        engine.attach(delay)
        engine.attach(distortion)
        engine.attach(pickedAudioPlayer)

        engine.connect(sixteethPlayer, to: playMixer, format: audioFormat)
        engine.connect(eightPlayer, to: playMixer, format: audioFormat)
        engine.connect(quarterPlayer, to: playMixer, format: audioFormat)
        engine.connect(kitPlayer, to: playMixer, format: audioFormat)
        engine.connect(trackPlayer, to: playMixer, format: audioFormat)
        engine.connect(pickedAudioPlayer, to: playMixer, format: audioFormat)
        engine.connect(playMixer, to: rateEffect, format: audioFormat)
        engine.connect(rateEffect, to: effectMixer, format: audioFormat)
        engine.connect(effectMixer, to: engine.mainMixerNode, format: audioFormat)
    }

    func tearDownEngine() {
        engine.reset()
        sixteenthAudioFileURL = nil
        eightAudioURL  =  nil
        quaterAudioURL  =  nil
        kitAudioFileURL  =  nil
        trackAudioFileURL  =  nil
        micInputNode.reset()

        engine.disconnectNodeOutput(sixteethPlayer)
        engine.disconnectNodeOutput(eightPlayer)
        engine.disconnectNodeOutput(kitPlayer)
        engine.disconnectNodeOutput(trackPlayer)
        engine.disconnectNodeOutput(pickedAudioPlayer)
        engine.disconnectNodeOutput(playMixer)
        engine.disconnectNodeOutput(rateEffect)
        engine.disconnectNodeOutput(effectMixer)

        engine.detach(sixteethPlayer)
        engine.detach(eightPlayer)
        engine.detach(quarterPlayer)
        engine.detach(kitPlayer)
        engine.detach(trackPlayer)
        engine.detach(rateEffect)
        engine.detach(reverb)
        engine.detach(playMixer)
        engine.detach(effectMixer)
        engine.detach(inputMixer)
        engine.detach(recordingMixer)
        engine.detach(equalizer)
        engine.detach(delay)
        engine.detach(distortion)
        engine.detach(pickedAudioPlayer)

        sixteethPlayer.stop()
        eightPlayer.stop()
        quarterPlayer.stop()
        kitPlayer.stop()
        trackPlayer.stop()
        pickedAudioPlayer.stop()

        sixteenthPCMBuffer = nil
        eightPCMBuffer = nil
        quaterPCMBuffer = nil
        kitPCMBuffer = nil
        trackPCMBuffer = nil
        musicFileBuffer = nil
    }

    func prepareAndStartEngine() {
        do {
            if !engine.isRunning {
                engine.prepare()
                try engine.start()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func setUpAudioSessionForPlayback() {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default , options: [AVAudioSession.CategoryOptions.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setInputGain(1.0)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)

            try audioSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlaybackAndRecord failed.")
        }
    }

    @IBAction func playTapped(_ sender: Any) {
        if sixteethPlayer.isPlaying {
            pausePlayback()
            playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "Play_Button"), for: .normal)
            if engine.isRunning {
                startPlayback()
            } else {
                prepareAndStartEngine()
                startPlayback()
            }
        }
    }

    func startPlayback() {
        //if not using headphones show toast message
        if !AVAudioSession.isHeadphonesConnected {
            self.showHeadphoneMessage()
        }
        UIApplication.shared.isIdleTimerDisabled = true
        let currentTime = sixteethPlayer.lastRenderTime
        if sixteethPlayer.isPlaying {
            sixteethPlayer.pause()
        } else {
            sixteethPlayer.play(at: currentTime)
        }
        if eightPlayer.isPlaying {
            eightPlayer.pause()
        } else {
            eightPlayer.play(at: currentTime)
        }
        if quarterPlayer.isPlaying {
            quarterPlayer.pause()
        } else {
            quarterPlayer.play(at: currentTime)
        }
        if kitPlayer.isPlaying {
            kitPlayer.pause()
        } else {
            kitPlayer.play(at: currentTime)
        }
        if trackPlayer.isPlaying {
            trackPlayer.pause()
        } else {
            trackPlayer.play(at: currentTime)
        }
        if pickedAudioPlayer.isPlaying {
            pickedAudioPlayer.pause()
        } else {
            pickedAudioPlayer.play(at: currentTime)
        }
        updateViewForPlayerState()
    }

    func pausePlayback() {
        UIApplication.shared.isIdleTimerDisabled = false
        sixteethPlayer.pause()
        eightPlayer.pause()
        quarterPlayer.pause()
        kitPlayer.pause()
        trackPlayer.pause()
        pickedAudioPlayer.pause()
        updateViewForPlayerState()
        musicPaused = true
        timer.invalidate()
    }

    func updateViewForPlayerState() {
        if sixteethPlayer.isPlaying {
            playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        } else {
            playButton.setImage(UIImage(named: "Play_Button"), for: .normal)
        }
    }

    @objc func updateViewForPlayerInfo() {
        let realCurrentFrame = CGFloat(currentFrame) - (CGFloat(audioLengthSamples) * CGFloat(loopCounter))

        let progress = CGFloat(realCurrentFrame) / CGFloat(audioLengthSamples)
        if progress >= 0.99 {
            model.resetProgress()
            loopCounter += 1
        }
        model.updateProgressForPlayer(progress: progress)
        //model.slider.value = Float(progress)
        print(" CURRENT TIME = \(currentTimeInSeconds().formattedTimeString())  - \(model.slider.maximumValue)")
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "")
    }

    @objc func openMicTapped(_ sender: Any) {
        if isMicOpen {
            closeMic()
        } else {
            openMic()
        }
    }

    @objc func recordTapped(_ sender: Any) {
        if isRecording {
            stopRecordingMixerOutput()
        } else {
            startRecordingMixerOutput()
        }
    }

    func startRecordingMixerOutput() {
        let fileName = "\(drumLoop.LoopName) \(Date().toMillis() ?? 0).caf"
        let outputURL = getRecordingsDirectory().appendingPathComponent(fileName)
        do {
            mixerOutputFile = try AVAudioFile(forWriting: outputURL, settings: engine.mainMixerNode.outputFormat(forBus: 0).settings)
        } catch {
            print("Setting AVAudioOutput file failed.")
            return
        }
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse,.repeat, .allowUserInteraction], animations: {
            self.recordButton.alpha = 0.5
            self.recordButton.setImage(UIImage(named: "Red_Rec_Icon"), for: .normal)
        })
        isRecording = true
        let recordingFormat = engine.mainMixerNode.outputFormat(forBus:0)

        engine.mainMixerNode.installTap(onBus: bus, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in

            guard let buffer = buffer else { return }
            do {
                try self.mixerOutputFile.write(from: buffer)
            } catch {
                print("Error writing to buffer")
                return
            }
        }
    }

    func stopRecordingMixerOutput() {
        if isRecording {
            engine.mainMixerNode.removeTap(onBus: 0)
            self.recordButton.layer.removeAllAnimations()
            self.recordButton.alpha = 1.0
            self.recordButton.setImage(UIImage(named: "Rec_Icon"), for: .normal)
        }
        isRecording = false
    }

    func recordingIsAvailable() -> Bool {
        return mixerOutputFileURL != nil
    }


    func openMic() {
        isMicOpen = true
        let inputFormat = engine.inputNode.inputFormat(forBus: 0)
        micButton.setImage(UIImage(named: "Mic_Icon_on"), for: .normal)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.autoreverse,.repeat, .allowUserInteraction], animations: {
            self.micButton.alpha = 0.5
        })

        inputMixer.outputVolume = 0.5

        engine.connect(engine.inputNode, to: reverb, format: inputFormat)
        engine.connect(reverb, to: equalizer, format: inputFormat)
        engine.connect(equalizer, to: delay, format: inputFormat)
        engine.connect(delay, to: distortion, format: inputFormat)
        engine.connect(distortion, to: inputMixer, format: inputFormat)

        engine.connect(inputMixer, to: engine.mainMixerNode, format: inputFormat)
    }

    func closeMic() {
        if isMicOpen {
            engine.disconnectNodeOutput(inputMixer)
            self.micButton.layer.removeAllAnimations()
            self.micButton.alpha = 1.0
            micButton.setImage(UIImage(named: "Mic_Icon"), for: .normal)
        }
        isMicOpen = false
    }

    override func didReceiveMemoryWarning() {
        print("Run out of memory Jam")
    }
}

extension JamViewController {

    @objc func sixteenthSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                let volume = value / 10.0
                sixteethPlayer.volume = volume
            }
        }
    }

    @objc func eigthtSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                let volume = value / 10.0
                eightPlayer.volume = volume
            }
        }
    }

    @objc func quaterSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                let volume = value / 10.0
                quarterPlayer.volume = volume
            }
        }
    }

    @objc func kitSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                let volume = value / 10.0
                kitPlayer.volume = volume
            }
        }
    }

    @objc func trackSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                let volume = value / 10.0
                trackPlayer.volume = volume
            }
        }
    }

    @objc func mixChanged(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                inputMixer.outputVolume = (100-value) / 100
                effectMixer.outputVolume = value / 100
            }
        }
    }
}
