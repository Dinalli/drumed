//
//  PlayMusicViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 14/08/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit
import MediaPlayer
import FirebaseAnalytics
import SwiftUI

class PlayMusicViewController: BasePlaybackViewController {

    var showPicker: Bool = false
    let model = PlayMusicViewModel()

    var circlePlayerView: CirclePlayerView!
    var effectsScroller: UIScrollView!
    var playControlView: PlayerView!

    var volumeSlider: HorizontalSilder!
    var speedSlider: HorizontalSilder!
    var playButton: UIButton!
    var micButton: UIButton!

    var loopCounter = 0

    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    // amount to skip on rewind or fast forward
    let SKIP_TIME = 1.0
    // amount to play between skips
    let SKIP_INTERVAL = 0.2
    // amount to skip on rewind or fast forward using timeslider
    let SKIP_TIMESILDER = 15.0

    var seconds: Int = 0
    var musicPaused: Bool = false
    var isRecording: Bool = false

    var micInputNode: AVAudioNode!
    var isMicOpen: Bool = false
    let bus = 0

    var mixerOutputFileURL: String!
    var mixerOutputFile: AVAudioFile!

    var updater: CADisplayLink?
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = musicPlayer.lastRenderTime,
            let playerTime = musicPlayer.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0

    var musicAudioFile: AVAudioFile? {
        didSet {
            if let musicAudioFile = musicAudioFile {
                audioLengthSamples = musicAudioFile.length
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate

                audioFormat = musicAudioFile.processingFormat
                musicFrameCount = UInt32(musicAudioFile.length)
                musicFileBuffer = AVAudioPCMBuffer(pcmFormat: musicAudioFile.processingFormat, frameCapacity: musicFrameCount!)
            }
        }
    }
    var musicAudioFileURL: URL? {
        didSet {
            if let musicAudioFileURL = musicAudioFileURL {
                musicAudioFile = try? AVAudioFile(forReading: musicAudioFileURL)
            }
        }
    }

    var audioBuffer: AVAudioPCMBuffer?
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture_full")!)
        showMediaPicker()
        let imageView = UIImageView(image: UIImage(named: "Drum-EdLogoMed"))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        let musicLibraryPicker = UIBarButtonItem(image: UIImage(named: "music_library"), style: .plain, target: self, action: #selector(showMediaPicker))
        self.navigationItem.rightBarButtonItems = [musicLibraryPicker]
        // Do any additional setup after loading the view.
        setUpAudioSession()
        setupAudioEngine()
        setUpNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showSwipeMessage()
    }

    @objc func showMediaPicker() {
        switch MPMediaLibrary.authorizationStatus() {
        case .authorized, .notDetermined:
            let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
            myMediaPickerVC.showsCloudItems = false
            myMediaPickerVC.allowsPickingMultipleItems = false
            myMediaPickerVC.showsItemsWithProtectedAssets = false
            myMediaPickerVC.delegate = self
            self.present(myMediaPickerVC, animated: true, completion: nil)
        case .denied:           showUserSettingsMessage(title: "Media Access", message: "Media access required to load your own songs to play along to.")
        default:
            break
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if self.isMovingFromParent {
            if engine.isRunning {
                engine.stop()
            }
            tearDownEngine()
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        model.layoutViews(view: self.view)
        playButton = model.playButton
        playButton.addTarget(self, action: #selector(playTapped(_:)), for: .touchUpInside)
        micButton = model.micButton
        micButton.addTarget(self, action: #selector(openMicTapped(_:)), for: .touchUpInside)
        model.playControlView.setSpeedLabel()
    }

    func setUpNotifications() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name:AVAudioSession.routeChangeNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleSessionInteruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)

            // Play Controls Notifications
            NotificationCenter.default.addObserver(self, selector: #selector(mixValueChanged(_:)), name: Notification.Name(rawValue: kMixValueChanged), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(rateValueChanged(_:)), name: Notification.Name(rawValue: kRateValueChanged), object: nil)

            NotificationCenter.default.addObserver(self, selector: #selector(rateSliderChanged(_:)), name: Notification.Name(rawValue: kSpeedValueChanged), object: nil)

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
        }


    @objc func handleSessionInteruption(_ notification: Notification) {
        guard let value = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType =  AVAudioSession.InterruptionType(rawValue: value)
            else {
                print("notification.userInfo?[AVAudioSessionInterruptionTypeKey]", notification.userInfo?[AVAudioSessionInterruptionTypeKey]! ?? "No key")
                return }
        switch interruptionType {
        case .began:
            pausePlayback()
            do {
                try audioSession.setActive(false)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        default :
            if let optionValue = (notification.userInfo?[AVAudioSessionInterruptionOptionKey] as? NSNumber)?.uintValue, AVAudioSession.InterruptionOptions(rawValue: optionValue) == .shouldResume {
                // ok to resume playing, re activate session and resume playing
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

    func setupAudioEngine() {
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
        playMixer.outputVolume = 0.5
        connectNodes()
    }

    func prepareAndStartEngineAfterTrackPicked() {
        guard let musicAudioFile = musicAudioFile else { return }
        stopEngineAndReset()
        do {
            try musicAudioFile.read(into: musicFileBuffer!)
            musicPlayer.scheduleBuffer(musicFileBuffer!, at: nil, options:.loops, completionHandler: nil)
            musicPlayer.volume = 0.1
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateViewForPlayerInfo), userInfo: nil, repeats: true)
            prepareAndStartEngine()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func stopEngineAndReset() {
        if engine.isRunning {
            engine.stop()
        }
        if musicPlayer.isPlaying {
            updater?.isPaused = true
            pausePlayback()
            playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        }
        self.loopCounter = 0
    }

    func connectNodes() {
        inputMixer.outputVolume = 0.5
        
        micInputNode = engine.inputNode
        engine.attach(musicPlayer)

        engine.attach(rateEffect)
        engine.attach(reverb)
        engine.attach(playMixer)
        engine.attach(effectMixer)
        engine.attach(inputMixer)
        engine.attach(recordingMixer)
        engine.attach(equalizer)
        engine.attach(delay)
        engine.attach(distortion)

        engine.connect(musicPlayer, to: playMixer, format: audioFormat)
        engine.connect(playMixer, to: rateEffect, format: audioFormat)
        engine.connect(rateEffect, to: effectMixer, format: audioFormat)
        engine.connect(effectMixer, to: engine.mainMixerNode, format: audioFormat)
        engine.mainMixerNode.volume = 0.1
    }

    func tearDownEngine() {
        engine.reset()
        musicAudioFileURL = nil
        micInputNode.reset()

        engine.disconnectNodeOutput(musicPlayer)
        engine.disconnectNodeOutput(playMixer)
        engine.disconnectNodeOutput(rateEffect)
        engine.disconnectNodeOutput(effectMixer)

        engine.detach(rateEffect)
        engine.detach(reverb)
        engine.detach(playMixer)
        engine.detach(effectMixer)
        engine.detach(inputMixer)
        engine.detach(recordingMixer)
        engine.detach(equalizer)
        engine.detach(delay)
        engine.detach(distortion)

        musicPlayer.stop()
        musicFileBuffer = nil
    }

    func prepareAndStartEngine() {
        engine.prepare()
        do {
            if !engine.isRunning {
                try engine.start()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func setUpAudioSession() {
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
        if musicPlayer.isPlaying {
            updater?.isPaused = true
            pausePlayback()
            playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        } else {
            updater?.isPaused = false
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
        let currentTime = musicPlayer.lastRenderTime
        if musicPlayer.isPlaying {
            musicPlayer.pause()
        } else {
            musicPlayer.play(at: currentTime)
        }
    }

    func pausePlayback() {
        UIApplication.shared.isIdleTimerDisabled = false
        musicPlayer.pause()
        musicPaused = true
        if timer != nil {
            timer.invalidate()
        }
    }

    @objc func updateViewForPlayerInfo() {
        let realCurrentFrame = CGFloat(currentFrame) - (CGFloat(audioLengthSamples) * CGFloat(loopCounter))

        let progress = CGFloat(realCurrentFrame) / CGFloat(audioLengthSamples)
        let progressString = String(format: "%.2f",progress)
        print("Progress \(progressString) Real Frame \(realCurrentFrame) Sample Len \(audioLengthSamples)" )

        if progress >= 0.99 {
            model.resetProgress()
            loopCounter += 1
        }

        model.updateProgressForPlayer(progress: progress)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "")
    }

    @IBAction func openMicTapped(_ sender: Any) {
        if isMicOpen {
            closeMic()
        } else {
            openMic()
        }
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
        print("Run out of memory Play")
    }

    @IBAction func openMediaPicker(_ sender: Any) {
        let myMediaPickerVC = MPMediaPickerController(mediaTypes: MPMediaType.music)
        myMediaPickerVC.showsCloudItems = false
        myMediaPickerVC.allowsPickingMultipleItems = false
        myMediaPickerVC.showsItemsWithProtectedAssets = false
        myMediaPickerVC.delegate = self
        self.present(myMediaPickerVC, animated: true, completion: nil)
    }
}

extension PlayMusicViewController: MPMediaPickerControllerDelegate {

    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        mediaPicker.dismiss(animated: true, completion: nil)
        let mediaItem: MPMediaItem = mediaItemCollection.items[0]
        musicAudioFileURL = mediaItem.assetURL
        prepareAndStartEngineAfterTrackPicked()
        model.updateViewForNewMediaItem(item: mediaItem)
        Analytics.logEvent("play_music", parameters: [
            "artist": mediaItem.artist ?? "No Artist" as NSObject,
            "track": mediaItem.title ?? "No track title" as NSObject
          ])
    }

    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }
}
