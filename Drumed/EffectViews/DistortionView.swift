//
//  DistortionView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit

let kDistortionWetDryValueChanged = "kDistortionWetDryValueChanged"
let kDistortionGainValueChanged = "kDistortionGainValueChanged"
let kDistortionPresetChanged = "kDistortionPresetChanged"

class DistortionView: UIView {

    var distortion = AVAudioUnitDistortion()
    enum DistortionPresets: String, CaseIterable {
        case drumsBitBrush = "drumsBitBrush"
        case drumsBufferBeats = "drumsBufferBeats"
        case drumsLoFi = "drumsLoFi"
        case multiBrokenSpeaker = "multiBrokenSpeaker"
        case multiCellphoneConcert = "multiCellphoneConcert"
        case multiDecimated1 = "multiDecimated1"
        case multiDecimated2 = "multiDecimated2"
        case multiDecimated3 = "multiDecimated3"
        case multiDecimated4 = "multiDecimated4"
        case multiDistortedFunk = "multiDistortedFunk"
        case multiDistortedSquared = "multiDistortedSquared"
        case multiEcho1 = "multiEcho1"
        case multiEcho2 = "multiEcho2"
        case multiEchoTight1 = "multiEchoTight1"
        case multiEchoTight2 = "multiEchoTight2"
        case multiEverythingIsBroken = "multiEverythingIsBroken"
        case speechAlienChatter = "speechAlienChatter"
        case speechCosmicInterference = "speechCosmicInterference"
        case speechGoldenPi = "speechGoldenPi"
        case speechRadioTower = "speechRadioTower"
        case speechWaves = "speechWaves"
    }

    var distortionSlider: HorizontalSilder!
    var gainSlider: HorizontalSilder!
    var distortionPicker: UIPickerView!

    var distortionLabel: UILabel!
    var distortionMinLabel: UILabel!
    var distortionMaxLabel: UILabel!
    var distortionCurrentLabel: UILabel!

    var gainLabel: UILabel!
    var gainMinLabel: UILabel!
    var gainMaxLabel: UILabel!
    var gainCurrentLabel: UILabel!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {

        distortionSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        distortionSlider.minimumValue = 0
        distortionSlider.maximumValue = 100
        distortionSlider.value = 0
        self.addSubview(distortionSlider)
        distortionSlider.addTarget(self, action: #selector(wetdryValueChanged(_:)), for: .valueChanged)

        gainSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        gainSlider.minimumValue = -80
        gainSlider.maximumValue = 20
        gainSlider.value = -80
        self.addSubview(gainSlider)
        gainSlider.addTarget(self, action: #selector(gainValueChanged(_:)), for: .valueChanged)

        distortionPicker = UIPickerView(frame: CGRect(x: 20, y: 160, width: self.frame.size.width - 40, height: 100))
        distortionPicker.dataSource = self
        distortionPicker.delegate = self
        self.addSubview(distortionPicker)

        if let effectRow = defaultsHelper.getDefault(for: "DistortionEffectRow") as? Int {
            distortionPicker.selectRow(effectRow, inComponent: 0, animated: true)
            NotificationCenter.default.post(name: Notification.Name(kDistortionPresetChanged), object:nil, userInfo: ["value":"\(DistortionPresets.allCases[effectRow].rawValue)"])
        }

        if let distortionValue = defaultsHelper.getDefault(for: "Distortion") as? Float {
            distortionSlider.value = distortionValue
            NotificationCenter.default.post(name: Notification.Name(kDistortionWetDryValueChanged), object:nil, userInfo: ["value":distortionSlider.value])
        }

        if let gainValue = defaultsHelper.getDefault(for: "DistortionGain") as? Float {
            gainSlider.value = gainValue
            NotificationCenter.default.post(name: Notification.Name(kDistortionGainValueChanged), object:nil, userInfo: ["value":gainSlider.value])
        }

        createSliderLabels()
        setAutoLayout()
    }

    fileprivate func createSliderLabels() {
        distortionLabel = UILabel()
        distortionLabel.text = "Distortion"
        distortionLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        distortionLabel.textColor = UIColor(named: "TextColor")
        distortionLabel.textAlignment = .center
        self.addSubview(distortionLabel)

        distortionMinLabel = UILabel()
        distortionMinLabel.text = "Dry"
        distortionMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        distortionMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(distortionMinLabel)

        distortionMaxLabel = UILabel()
        distortionMaxLabel.text = "Wet"
        distortionMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        distortionMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(distortionMaxLabel)

        distortionCurrentLabel = UILabel()
        distortionCurrentLabel.text = "50"
        distortionCurrentLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        distortionCurrentLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(distortionCurrentLabel)

        gainLabel = UILabel()
        gainLabel.text = "Gain"
        gainLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        gainLabel.textColor = UIColor(named: "TextColor")
        gainLabel.textAlignment = .center
        self.addSubview(gainLabel)

        gainMinLabel = UILabel()
        gainMinLabel.text = "0"
        gainMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        gainMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(gainMinLabel)

        gainMaxLabel = UILabel()
        gainMaxLabel.text = "100"
        gainMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        gainMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(gainMaxLabel)
    }

    func setAutoLayout() {
        distortionLabel.translatesAutoresizingMaskIntoConstraints = false
        distortionMinLabel.translatesAutoresizingMaskIntoConstraints = false
        distortionMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        distortionCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        distortionSlider.translatesAutoresizingMaskIntoConstraints = false
        gainLabel.translatesAutoresizingMaskIntoConstraints = false
        gainMinLabel.translatesAutoresizingMaskIntoConstraints = false
        gainMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        gainSlider.translatesAutoresizingMaskIntoConstraints = false
        distortionPicker.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: distortionSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: distortionSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: distortionSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: distortionMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: distortionSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: distortionMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: distortionSlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: distortionMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: distortionLabel as Any, attribute: .top, relatedBy: .equal, toItem: distortionSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: distortionLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: distortionSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: distortionCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: distortionSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: distortionCurrentLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: distortionSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: distortionMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: distortionSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: distortionMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: distortionSlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: distortionMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: gainSlider as Any, attribute: .top, relatedBy: .equal, toItem: distortionSlider, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: gainSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: gainSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: gainMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: gainSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: gainMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: gainSlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: gainMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: gainLabel as Any, attribute: .top, relatedBy: .equal, toItem: gainSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: gainLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: gainSlider, attribute: .centerX, multiplier: 1, constant: 0),
 
            NSLayoutConstraint(item: gainMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: gainSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: gainMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: gainSlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: gainMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: distortionPicker as Any, attribute: .top, relatedBy: .equal, toItem: gainSlider, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: distortionPicker as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: distortionPicker as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: distortionPicker as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 150)
        ])
    }

    @objc func wetdryValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kDistortionWetDryValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "Distortion", with: sender.value)
    }

    @objc func gainValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kDistortionGainValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "DistortionGain", with: sender.value)
    }
}

extension DistortionView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NotificationCenter.default.post(name: Notification.Name(kDistortionPresetChanged), object:nil, userInfo: ["value":"\(DistortionPresets.allCases[row].rawValue)"])
        defaultsHelper.setDefault(for: "DistortionEffectRow", with: row)
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = "\(DistortionPresets.allCases[row].rawValue)"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "TextColor")!, NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 16)!])
    }
}

extension DistortionView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DistortionPresets.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(DistortionPresets.allCases[row].rawValue)"
    }
}
