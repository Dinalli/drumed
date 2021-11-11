//
//  BasePlaybackViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 13/06/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit
import MediaPlayer

class BasePlaybackViewController: UIViewController {

    var reverbView: ReverbView!
    var distortionView: DistortionView!
    var eqView: EQView!
    var delayView: DelayView!

    var engine = AVAudioEngine()
    var musicPlayer = AVAudioPlayerNode()

    var audioSampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var audioLengthSamples: AVAudioFramePosition = 0

    var audioFormat: AVAudioFormat?
    var musicFileBuffer: AVAudioPCMBuffer?
    var musicFrameCount: UInt32?

    let playMixer = AVAudioMixerNode()
    let effectMixer = AVAudioMixerNode()
    let inputMixer = AVAudioMixerNode()
    let recordingMixer = AVAudioMixerNode()

    var rateEffect = AVAudioUnitTimePitch()
    var reverb = AVAudioUnitReverb()
    var delay = AVAudioUnitDelay()
    var distortion = AVAudioUnitDistortion()

    var equalizer: AVAudioUnitEQ!

    let audioSession = AVAudioSession.sharedInstance()
    var audioRecorder: AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @objc func rateSliderChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                if value < Float(1.1) && value > Float(0.98) {
                    rateEffect.rate = 1.0
                } else {
                    rateEffect.rate = value
                }
            }
        }
    }

    @objc func mixValueChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                inputMixer.outputVolume = (100-value) / 100
                effectMixer.outputVolume = value / 100
            }
        }
    }

    @objc func rateValueChanged(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                rateEffect.rate = value
            }
        }
    }

    @objc func band0Value(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[0].gain = value
            }
        }
    }

    @objc func band1Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[1].gain = value
            }
        }
    }

    @objc func band2Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[2].gain = value
            }
        }
    }

    @objc func band3Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[3].gain = value
            }
        }
    }

    @objc func band4Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[4].gain = value
            }
        }
    }

    @objc func band5Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[5].gain = value
            }
        }
    }

    @objc func band6Value(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                equalizer.bands[6].gain = value
            }
        }
    }

    @objc func reverbMixValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                reverb.wetDryMix = value
            }
        }
    }

    @objc func reverbPresetSelected(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? String {
                switch value {
                case "smallRoom":
                    reverb.loadFactoryPreset(.smallRoom)
                case "mediumRoom":
                    reverb.loadFactoryPreset(.mediumRoom)
                case "largeRoom":
                    reverb.loadFactoryPreset(.largeRoom)
                case "mediumHall":
                    reverb.loadFactoryPreset(.mediumHall)
                case "largeHall":
                    reverb.loadFactoryPreset(.largeHall)
                case "plate":
                    reverb.loadFactoryPreset(.plate)
                case "mediumChamber":
                    reverb.loadFactoryPreset(.mediumChamber)
                case "largeChamber":
                    reverb.loadFactoryPreset(.largeChamber)
                case "cathedral":
                    reverb.loadFactoryPreset(.cathedral)
                case "largeRoom2":
                    reverb.loadFactoryPreset(.largeRoom2)
                case "mediumHall2":
                    reverb.loadFactoryPreset(.mediumHall2)
                case "mediumHall3":
                    reverb.loadFactoryPreset(.mediumHall3)
                case "largeHall2":
                    reverb.loadFactoryPreset(.largeHall2)
                default:
                    reverb.loadFactoryPreset(.smallRoom)
                }
            }
        }
    }

    @objc func volumeChanged(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                inputMixer.outputVolume = value
            }
        }
    }

    @objc func effectMusicMixValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                effectMixer.outputVolume = value
            }
        }
    }

    @objc func distortionPresetChangedValue(_ notification: NSNotification) {
        let preWetDry = distortion.wetDryMix
        let preGain = distortion.preGain
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? String {
                switch value {
                case "drumsBitBrush":
                    distortion.loadFactoryPreset(.drumsBitBrush)
                case "drumsBufferBeats":
                    distortion.loadFactoryPreset(.drumsBufferBeats)
                case "drumsLoFi":
                    distortion.loadFactoryPreset(.drumsLoFi)
                case "multiBrokenSpeaker":
                    distortion.loadFactoryPreset(.multiBrokenSpeaker)
                case "multiCellphoneConcert":
                    distortion.loadFactoryPreset(.multiCellphoneConcert)
                case "multiDecimated1":
                    distortion.loadFactoryPreset(.multiDecimated1)
                case "multiDecimated2":
                    distortion.loadFactoryPreset(.multiDecimated2)
                case "multiDecimated3":
                    distortion.loadFactoryPreset(.multiDecimated3)
                case "multiDecimated4":
                    distortion.loadFactoryPreset(.multiDecimated4)
                case "multiDistortedFunk":
                    distortion.loadFactoryPreset(.multiDistortedFunk)
                case "multiDistortedSquared":
                    distortion.loadFactoryPreset(.multiDistortedSquared)
                case "multiEcho1":
                    distortion.loadFactoryPreset(.multiEcho1)
                case "multiEcho2":
                    distortion.loadFactoryPreset(.multiEcho2)
                case "multiEchoTight1":
                    distortion.loadFactoryPreset(.multiEchoTight1)
                case "multiEchoTight2":
                    distortion.loadFactoryPreset(.multiEchoTight2)
                case "multiEverythingIsBroken":
                    distortion.loadFactoryPreset(.multiEverythingIsBroken)
                case "speechAlienChatter":
                    distortion.loadFactoryPreset(.speechAlienChatter)
                case "speechCosmicInterference":
                    distortion.loadFactoryPreset(.speechCosmicInterference)
                case "speechGoldenPi":
                    distortion.loadFactoryPreset(.speechGoldenPi)
                case "speechRadioTower":
                    distortion.loadFactoryPreset(.speechRadioTower)
                case "speechWaves":
                    distortion.loadFactoryPreset(.speechWaves)
                default:
                    distortion.loadFactoryPreset(.multiDistortedCubed)
                }
            }
        }
        // Reset these as they get changed by the preset loaded.
        distortion.preGain = preGain
        distortion.wetDryMix = preWetDry
    }

    @objc func distortionGainMixValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                distortion.preGain = value
            }
        }
    }

    @objc func distortionWetDryMixValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                distortion.wetDryMix = value
            }
        }
    }

    @objc func delayWetDryMixValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                delay.wetDryMix = value
            }
        }
    }

    @objc func delayTimeValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Double {
                delay.delayTime = value
            }
        }
    }

    @objc func delayFeedbackValue(_ notification: NSNotification)  {
        if let dict = notification.userInfo as NSDictionary? {
            if let value = dict["value"] as? Float {
                delay.feedback = value
            }
        }
    }

    func showSwipeMessage() {
        let chevronImage = UIImageView(image: UIImage(systemName: "hand.draw"))
        chevronImage.frame = CGRect(x: 10, y: 20, width: 44, height: 44)
        chevronImage.tintColor = UIColor.white
        
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.clear
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont(name: "Roboto", size: 18.0)
        toastLabel.text = "You can swipe left for more effects..."
        toastLabel.lineBreakMode = .byWordWrapping
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0
        
        let toastHeight = toastLabel.intrinsicContentSize.height * 2
        let toastWidth = toastLabel.intrinsicContentSize.width
        
        let toastView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 440, width: toastWidth, height: 80))
        toastLabel.frame = CGRect(x: 50, y: 20, width: toastWidth-80, height: toastHeight)
        toastView.backgroundColor = UIColor.black
        toastView.layer.cornerRadius = 10
        toastView.clipsToBounds  =  true
        toastView.center.x = self.view.center.x
        toastView.addSubview(chevronImage)
        toastView.addSubview(toastLabel)
        self.view.addSubview(toastView)
        UIView.animate(withDuration: 5.0, delay: 0.0, options: .curveEaseOut, animations: {
            toastView.alpha = 0.0
        }, completion: {(_ ) in
            toastView.removeFromSuperview()
        })
    }
}
