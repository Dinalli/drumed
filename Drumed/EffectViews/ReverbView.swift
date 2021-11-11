//
//  ReverbView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit

let kReverbWetDryValueChanged = "kReverbWetDryValueChanged"
let kReverbPresetChanged = "kReverbPresetChanged"

class ReverbView: UIView {

    var reverb = AVAudioUnitReverb()

    enum ReverbPresets: String, CaseIterable {
        case smallRoom = "smallRoom"
        case mediumRoom = "mediumRoom"
        case largeRoom = "largeRoom"
        case mediumHall = "mediumHall"
        case largeHall = "largeHall"
        case plate = "plate"
        case mediumChamber = "mediumChamber"
        case largeChamber = "largeChamber"
        case cathedral = "cathedral"
        case largeRoom2 = "largeRoom2"
        case mediumHall2 = "mediumHall2"
        case mediumHall3 = "mediumHall3"
        case largeHall2 = "largeHall2"
    }

    var reverbSlider: HorizontalSilder!
    var effectPicker: UIPickerView!

    var reverbLabel: UILabel!
    var reverbMinLabel: UILabel!
    var reverbMaxLabel: UILabel!
    var reverbCurrentLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {

        reverbSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        reverbSlider.minimumValue = 0
        reverbSlider.maximumValue = 100
        reverbSlider.value = 0
        self.addSubview(reverbSlider)
        reverbSlider.addTarget(self, action: #selector(mixSliderChanged(_:)), for: .valueChanged)

        effectPicker = UIPickerView(frame: CGRect(x: 20, y: 160, width: self.frame.size.width - 40, height: 150))
        effectPicker.dataSource = self
        effectPicker.delegate = self
        self.addSubview(effectPicker)

        if let reverbValue = defaultsHelper.getDefault(for: "Reverb") as? Float {
            reverbSlider.value = reverbValue
            NotificationCenter.default.post(name: Notification.Name(kReverbWetDryValueChanged), object:nil, userInfo: ["value":reverbSlider.value])
        }

        if let effectRow = defaultsHelper.getDefault(for: "ReverbEffectRow") as? Int {
            effectPicker.selectRow(effectRow, inComponent: 0, animated: true)
            NotificationCenter.default.post(name: Notification.Name(kReverbPresetChanged), object:nil, userInfo:  ["value":"\(ReverbPresets.allCases[effectRow].rawValue)"])
        }

        createSliderLabels()
        setAutoLayout()
    }

    fileprivate func createSliderLabels() {
        reverbLabel = UILabel()
        reverbLabel.text = "Reverb"
        reverbLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        reverbLabel.textColor = UIColor(named: "TextColor")
        reverbLabel.textAlignment = .center
        self.addSubview(reverbLabel)

        reverbMinLabel = UILabel()
        reverbMinLabel.text = "Dry"
        reverbMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        reverbMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(reverbMinLabel)

        reverbMaxLabel = UILabel()
        reverbMaxLabel.text = "Wet"
        reverbMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        reverbMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(reverbMaxLabel)

        reverbCurrentLabel = UILabel()
        reverbCurrentLabel.text = "50"
        reverbCurrentLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        reverbCurrentLabel.textColor = UIColor(named: "TextColor")
        reverbCurrentLabel.textAlignment = .center
        self.addSubview(reverbCurrentLabel)
    }

    func setAutoLayout() {
        reverbSlider.translatesAutoresizingMaskIntoConstraints = false
        reverbLabel.translatesAutoresizingMaskIntoConstraints = false
        reverbMinLabel.translatesAutoresizingMaskIntoConstraints = false
        reverbMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        reverbCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        effectPicker.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: reverbSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 80),
            NSLayoutConstraint(item: reverbSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: reverbSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: reverbMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: reverbSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: reverbMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: reverbSlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: reverbMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: reverbLabel as Any, attribute: .top, relatedBy: .equal, toItem: reverbSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: reverbLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: reverbSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: reverbCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: reverbSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: reverbCurrentLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: reverbSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: reverbMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: reverbSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: reverbMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: reverbSlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: reverbMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: effectPicker as Any, attribute: .top, relatedBy: .equal, toItem: reverbSlider, attribute: .bottom, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: effectPicker as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectPicker as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectPicker as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 150)
        ])
    }

    @objc func mixSliderChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kReverbWetDryValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "Reverb", with: sender.value)
    }
}

extension ReverbView: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NotificationCenter.default.post(name: Notification.Name(kReverbPresetChanged), object:nil, userInfo:  ["value":"\(ReverbPresets.allCases[row].rawValue)"])
        defaultsHelper.setDefault(for: "ReverbEffectRow", with: row)
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let string = "\(ReverbPresets.allCases[row].rawValue)"
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "TextColor")!, NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 16)!])
    }
}

extension ReverbView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ReverbPresets.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(ReverbPresets.allCases[row].rawValue)"
    }
}
