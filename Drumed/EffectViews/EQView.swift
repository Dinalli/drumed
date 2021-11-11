//
//  EQView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit

let kEQBand0ValueChanged = "kEQBand0ValueChanged"
let kEQBand1ValueChanged = "kEQBand1ValueChanged"
let kEQBand2ValueChanged = "kEQBand2ValueChanged"
let kEQBand3ValueChanged = "kEQBand3ValueChanged"
let kEQBand4ValueChanged = "kEQBand4ValueChanged"
let kEQBand5ValueChanged = "kEQBand5ValueChanged"
let kEQBand6ValueChanged = "kEQBand6ValueChanged"

class EQView: UIView {

    var equalizer: AVAudioUnitEQ!

    var eqLabel: UILabel!
    var band0Label: UILabel!
    var band1Label: UILabel!
    var band2Label: UILabel!
    var band3Label: UILabel!
    var band4Label: UILabel!
    var band5Label: UILabel!
    var band6Label: UILabel!

    var band0Slider: VerticalSlider!
    var band1Slider: VerticalSlider!
    var band2Slider: VerticalSlider!
    var band3Slider: VerticalSlider!
    var band4Slider: VerticalSlider!
    var band5Slider: VerticalSlider!
    var band6Slider: VerticalSlider!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        eqLabel = UILabel()
        eqLabel.text = "EQ"
        eqLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        eqLabel.textColor = UIColor(named: "TextColor")
        eqLabel.textAlignment = .center
        self.addSubview(eqLabel)

        band0Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band0Slider.minimumValue = -96
        band0Slider.maximumValue = 24
        band0Slider.value = -36
        self.addSubview(band0Slider)

        band1Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band1Slider.minimumValue = -96
        band1Slider.maximumValue = 24
        band1Slider.value = -36
        self.addSubview(band1Slider)

        band2Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band2Slider.minimumValue = -96
        band2Slider.maximumValue = 24
        band2Slider.value = -36
        self.addSubview(band2Slider)

        band3Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band3Slider.minimumValue = -96
        band3Slider.maximumValue = 24
        band3Slider.value = -36
        self.addSubview(band3Slider)

        band4Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band4Slider.minimumValue = -96
        band4Slider.maximumValue = 24
        band4Slider.value = -36
        self.addSubview(band4Slider)

        band5Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band5Slider.minimumValue = -96
        band5Slider.maximumValue = 24
        band5Slider.value = -36
        self.addSubview(band5Slider)

        band6Slider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        band6Slider.minimumValue = -96
        band6Slider.maximumValue = 24
        band6Slider.value = -36
        self.addSubview(band6Slider)

        band0Slider.addTarget(self, action: #selector(slider0Changed), for: .valueChanged)
        band1Slider.addTarget(self, action: #selector(slider1Changed), for: .valueChanged)
        band2Slider.addTarget(self, action: #selector(slider2Changed), for: .valueChanged)
        band3Slider.addTarget(self, action: #selector(slider3Changed), for: .valueChanged)
        band4Slider.addTarget(self, action: #selector(slider4Changed), for: .valueChanged)
        band5Slider.addTarget(self, action: #selector(slider5Changed), for: .valueChanged)
        band6Slider.addTarget(self, action: #selector(slider6Changed), for: .valueChanged)

        if let sliderValue0 = defaultsHelper.getDefault(for: "EQSlider0") as? Float {
            band0Slider.value = sliderValue0
            NotificationCenter.default.post(name: Notification.Name(kEQBand0ValueChanged), object:nil, userInfo: ["value":band0Slider.value])
        }
        if let sliderValue1 = defaultsHelper.getDefault(for: "EQSlider1") as? Float {
            band1Slider.value = sliderValue1
            NotificationCenter.default.post(name: Notification.Name(kEQBand1ValueChanged), object:nil, userInfo: ["value":band1Slider.value])
        }
        if let sliderValue2 = defaultsHelper.getDefault(for: "EQSlider2") as? Float {
            band2Slider.value = sliderValue2
            NotificationCenter.default.post(name: Notification.Name(kEQBand2ValueChanged), object:nil, userInfo: ["value":band2Slider.value])
        }
        if let sliderValue3 = defaultsHelper.getDefault(for: "EQSlider3") as? Float {
            band3Slider.value = sliderValue3
            NotificationCenter.default.post(name: Notification.Name(kEQBand3ValueChanged), object:nil, userInfo: ["value":band3Slider.value])
        }
        if let sliderValue4 = defaultsHelper.getDefault(for: "EQSlider4") as? Float {
            band4Slider.value = sliderValue4
            NotificationCenter.default.post(name: Notification.Name(kEQBand4ValueChanged), object:nil, userInfo: ["value":band4Slider.value])
        }
        if let sliderValue5 = defaultsHelper.getDefault(for: "EQSlider5") as? Float {
            band5Slider.value = sliderValue5
            NotificationCenter.default.post(name: Notification.Name(kEQBand5ValueChanged), object:nil, userInfo: ["value":band5Slider.value])
        }
        if let sliderValue6 = defaultsHelper.getDefault(for: "EQSlider6") as? Float {
            band6Slider.value = sliderValue6
            NotificationCenter.default.post(name: Notification.Name(kEQBand6ValueChanged), object:nil, userInfo: ["value":band6Slider.value])
        }

        addEQLabels()
        setAutoLayout()
    }

    func addEQLabels() {
        band0Label = UILabel()
        band0Label.text = "60 Hz"
        band0Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band0Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band0Label)

        band1Label = UILabel()
        band1Label.text = "100 Hz"
        band1Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band1Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band1Label)

        band2Label = UILabel()
        band2Label.text = "200 Hz"
        band2Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band2Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band2Label)

        band3Label = UILabel()
        band3Label.text = "400 Hz"
        band3Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band3Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band3Label)

        band4Label = UILabel()
        band4Label.text = "1000 Hz"
        band4Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band4Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band4Label)

        band5Label = UILabel()
        band5Label.text = "3000 Hz"
        band5Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band5Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band5Label)

        band6Label = UILabel()
        band6Label.text = "10000 Hz"
        band6Label.font = UIFont(name: "Rubik-Medium", size: 12)
        band6Label.textColor = UIColor(named: "TextColor")
        self.addSubview(band6Label)
    }

    func setAutoLayout() {
        let spaceWidth = self.frame.width / 7

        eqLabel.translatesAutoresizingMaskIntoConstraints = false
        band0Slider.translatesAutoresizingMaskIntoConstraints = false
        band0Label.translatesAutoresizingMaskIntoConstraints = false
        band1Slider.translatesAutoresizingMaskIntoConstraints = false
        band1Label.translatesAutoresizingMaskIntoConstraints = false
        band2Slider.translatesAutoresizingMaskIntoConstraints = false
        band2Label.translatesAutoresizingMaskIntoConstraints = false
        band3Slider.translatesAutoresizingMaskIntoConstraints = false
        band3Label.translatesAutoresizingMaskIntoConstraints = false
        band4Slider.translatesAutoresizingMaskIntoConstraints = false
        band4Label.translatesAutoresizingMaskIntoConstraints = false
        band5Slider.translatesAutoresizingMaskIntoConstraints = false
        band5Label.translatesAutoresizingMaskIntoConstraints = false
        band6Slider.translatesAutoresizingMaskIntoConstraints = false
        band6Label.translatesAutoresizingMaskIntoConstraints = false
        

        self.addConstraints([
            NSLayoutConstraint(item: eqLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eqLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eqLabel as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: band0Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band0Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: band0Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 35),

            NSLayoutConstraint(item: band0Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band0Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band0Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band0Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band0Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),


            NSLayoutConstraint(item: band1Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band1Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth),
            NSLayoutConstraint(item: band1Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 40),

            NSLayoutConstraint(item: band1Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band1Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band1Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band1Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band1Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),


            NSLayoutConstraint(item: band2Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band2Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*2),
            NSLayoutConstraint(item: band2Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 45),

            NSLayoutConstraint(item: band2Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band2Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band2Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band2Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band2Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),


            NSLayoutConstraint(item: band3Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band3Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*3),
            NSLayoutConstraint(item: band3Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: band3Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band3Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band3Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band3Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band3Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),



            NSLayoutConstraint(item: band4Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band4Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*4),
            NSLayoutConstraint(item: band4Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: band4Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band4Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band4Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band4Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band4Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),



            NSLayoutConstraint(item: band5Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band5Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*5),
            NSLayoutConstraint(item: band5Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 60),

            NSLayoutConstraint(item: band5Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band5Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band5Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band5Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band5Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),



            NSLayoutConstraint(item: band6Label as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: band6Label as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*6),
            NSLayoutConstraint(item: band6Label as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 55),

            NSLayoutConstraint(item: band6Slider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 160),
            NSLayoutConstraint(item: band6Slider as Any, attribute: .centerX, relatedBy: .equal, toItem: band6Label, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: band6Slider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: band6Slider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20)
        ])
    }

    @objc func slider0Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand0ValueChanged), object:nil, userInfo:  ["value":band0Slider.value])
        defaultsHelper.setDefault(for: "EQSlider0", with: band0Slider.value)
    }

    @objc func slider1Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand1ValueChanged), object:nil, userInfo: ["value":band1Slider.value])
        defaultsHelper.setDefault(for: "EQSlider1", with: band1Slider.value)
    }

    @objc func slider2Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand2ValueChanged), object:nil, userInfo: ["value":band2Slider.value])
        defaultsHelper.setDefault(for: "EQSlider2", with: band2Slider.value)
    }

    @objc func slider3Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand3ValueChanged), object:nil, userInfo: ["value":band3Slider.value])
        defaultsHelper.setDefault(for: "EQSlider3", with: band3Slider.value)
    }

    @objc func slider4Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand4ValueChanged), object:nil, userInfo: ["value":band4Slider.value])
        defaultsHelper.setDefault(for: "EQSlider4", with: band4Slider.value)
    }

    @objc func slider5Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand5ValueChanged), object:nil, userInfo: ["value":band5Slider.value])
        defaultsHelper.setDefault(for: "EQSlider5", with: band5Slider.value)
    }

    @objc func slider6Changed() {
        NotificationCenter.default.post(name: Notification.Name(kEQBand6ValueChanged), object:nil, userInfo: ["value":band6Slider.value])
        defaultsHelper.setDefault(for: "EQSlider6", with: band6Slider.value)
    }
}
