//
//  InstrumentPlayView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

let kSixteethSliderChanged = "kGuitarValueChanged"
let kEightSliderChanged = "kDrumsValueChanged"
let kQuarterValueChanged = "kBassValueChanged"
let kKitSliderChanged = "kKeysValueChanged"
let kTrackValueChanged = "kClickValueChanged"
let kSpeedValueChanged = "kSpeedValueChanged"

class InstrumentPlayView: UIView {

    var titleLabel: UILabel!
    var sixteenthLabel: UILabel!
    var eightLabel: UILabel!
    var quarterLabel: UILabel!
    var kitLabel: UILabel!
    var trackLabel: UILabel!
    var speedLabel: UILabel!
    var mixLabel: UILabel!
    var mixMinLabel: UILabel!
    var mixMaxLabel: UILabel!

    var sixteenthSlider: VerticalSlider!
    var eightSlider: VerticalSlider!
    var quaterSlider: VerticalSlider!
    var kitSlider: VerticalSlider!
    var trackSlider: VerticalSlider!
    var speedSlider: VerticalSlider!
    var mixSlider: HorizontalSilder!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        titleLabel = UILabel()
        titleLabel.text = "Instruments"
        titleLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        titleLabel.textColor = UIColor(named: "TextColor")
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)

        sixteenthSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        sixteenthSlider.minimumValue = 0
        sixteenthSlider.maximumValue = 10
        sixteenthSlider.value = 5
        self.addSubview(sixteenthSlider)

        eightSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        eightSlider.minimumValue = 0
        eightSlider.maximumValue = 10
        eightSlider.value = 5
        self.addSubview(eightSlider)

        quaterSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        quaterSlider.minimumValue = 0
        quaterSlider.maximumValue = 10
        quaterSlider.value = 5
        self.addSubview(quaterSlider)

        kitSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        kitSlider.minimumValue = 0
        kitSlider.maximumValue = 10
        kitSlider.value = 5
        self.addSubview(kitSlider)

        trackSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        trackSlider.minimumValue = 0
        trackSlider.maximumValue = 10
        trackSlider.value = 5
        self.addSubview(trackSlider)

        speedSlider = VerticalSlider(frame: CGRect(x: -60, y: 160, width: self.frame.size.height/1.5, height: 20))
        speedSlider.minimumValue = 0.5
        speedSlider.maximumValue = 1.5
        speedSlider.value = 1
        self.addSubview(speedSlider)

        mixSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        mixSlider.minimumValue = 0
        mixSlider.maximumValue = 100
        mixSlider.value = 50
        self.addSubview(mixSlider)

        addEQLabels()
        setAutoLayout()
        setUpTargetsForSliders()
    }

    func addEQLabels() {
        sixteenthLabel = UILabel()
        sixteenthLabel.text = "16th"
        sixteenthLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        sixteenthLabel.textColor = UIColor(named: "TextColor")
        sixteenthLabel.textAlignment = .center
        self.addSubview(sixteenthLabel)

        eightLabel = UILabel()
        eightLabel.text = "8th"
        eightLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        eightLabel.textColor = UIColor(named: "TextColor")
        eightLabel.textAlignment = .center
        self.addSubview(eightLabel)

        quarterLabel = UILabel()
        quarterLabel.text = "1/4"
        quarterLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        quarterLabel.textColor = UIColor(named: "TextColor")
        quarterLabel.textAlignment = .center
        self.addSubview(quarterLabel)

        kitLabel = UILabel()
        kitLabel.text = "Kit"
        kitLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        kitLabel.textAlignment = .center
        kitLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(kitLabel)

        trackLabel = UILabel()
        trackLabel.text = "Track"
        trackLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        trackLabel.textColor = UIColor(named: "TextColor")
        trackLabel.textAlignment = .center
        self.addSubview(trackLabel)

        speedLabel = UILabel()
        speedLabel.text = "Tempo  +/- 1x"
        speedLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        speedLabel.textColor = UIColor(named: "TextColor")
        speedLabel.textAlignment = .center
        speedLabel.numberOfLines = 0
        self.addSubview(speedLabel)

        mixLabel = UILabel()
        mixLabel.text = "Mix"
        mixLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        mixLabel.textColor = UIColor(named: "TextColor")
        mixLabel.textAlignment = .center
        self.addSubview(mixLabel)

        mixMinLabel = UILabel()
        mixMinLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        mixMinLabel.text = "Mic"
        mixMinLabel.textAlignment = .left
        self.addSubview(mixMinLabel)

        mixMaxLabel = UILabel()
        mixMaxLabel.font = UIFont(name: "Rubik-Medium", size: 12)
        mixMaxLabel.text = "Music"
        mixMaxLabel.textAlignment = .right
        self.addSubview(mixMaxLabel)
    }

    func setAutoLayout() {

        let spaceWidth = self.frame.width / 6

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        sixteenthSlider.translatesAutoresizingMaskIntoConstraints = false
        sixteenthLabel.translatesAutoresizingMaskIntoConstraints = false
        eightSlider.translatesAutoresizingMaskIntoConstraints = false
        eightLabel.translatesAutoresizingMaskIntoConstraints = false
        quaterSlider.translatesAutoresizingMaskIntoConstraints = false
        quarterLabel.translatesAutoresizingMaskIntoConstraints = false
        kitSlider.translatesAutoresizingMaskIntoConstraints = false
        kitLabel.translatesAutoresizingMaskIntoConstraints = false
        trackSlider.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        mixSlider.translatesAutoresizingMaskIntoConstraints = false
        mixLabel.translatesAutoresizingMaskIntoConstraints = false
        mixMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        mixMinLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: titleLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: titleLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: sixteenthLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: sixteenthLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: sixteenthLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: sixteenthSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: sixteenthSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: sixteenthLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: sixteenthSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: sixteenthSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: eightLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: eightLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth),
            NSLayoutConstraint(item: eightLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: eightSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: eightSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: eightLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: eightSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: eightSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: quarterLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: quarterLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*2),
            NSLayoutConstraint(item: quarterLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: quaterSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: quaterSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: quarterLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: quaterSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: quaterSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: kitLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: kitLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*3),
            NSLayoutConstraint(item: kitLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: kitSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: kitSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: kitLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: kitSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: kitSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: trackLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 30),
            NSLayoutConstraint(item: trackLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*4),
            NSLayoutConstraint(item: trackLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: trackSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: trackSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: trackLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: trackSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: trackSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: speedLabel as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: speedLabel as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: spaceWidth*5),
            NSLayoutConstraint(item: speedLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 50),

            NSLayoutConstraint(item: speedSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 140),
            NSLayoutConstraint(item: speedSlider as Any, attribute: .centerX, relatedBy: .equal, toItem: speedLabel, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: speedSlider as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: self.frame.size.height/1.5),
            NSLayoutConstraint(item: speedSlider as Any, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0, constant: 20),

            NSLayoutConstraint(item: mixLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -8),
            NSLayoutConstraint(item: mixLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: mixSlider, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mixLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0, constant: 30),

            NSLayoutConstraint(item: mixMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -3),
            NSLayoutConstraint(item: mixMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: mixSlider, attribute: .left, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: mixMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -3),
            NSLayoutConstraint(item: mixMaxLabel as Any, attribute: .right, relatedBy: .equal, toItem: mixSlider, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: mixSlider as Any, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 2),
            NSLayoutConstraint(item: mixSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: mixSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50)
        ])
    }

    fileprivate func setUpTargetsForSliders() {
        sixteenthSlider.addTarget(self, action: #selector(sixteenthChanged), for: .valueChanged)
        eightSlider.addTarget(self, action: #selector(eightSliderChanged), for: .valueChanged)
        quaterSlider.addTarget(self, action: #selector(quarterSliderChanged), for: .valueChanged)
        kitSlider.addTarget(self, action: #selector(kitSliderChanged), for: .valueChanged)
        trackSlider.addTarget(self, action: #selector(trackSliderChanged), for: .valueChanged)
        speedSlider.addTarget(self, action: #selector(speedChanged), for: .valueChanged)
        mixSlider.addTarget(self, action: #selector(mixChanged), for: .valueChanged)
    }

    @objc func sixteenthChanged() {
        NotificationCenter.default.post(name: Notification.Name(kSixteethSliderChanged), object:nil, userInfo: ["value":sixteenthSlider.value])
    }

    @objc func eightSliderChanged() {
        NotificationCenter.default.post(name: Notification.Name(kEightSliderChanged), object:nil, userInfo: ["value":eightSlider.value])
    }

    @objc func quarterSliderChanged() {
        NotificationCenter.default.post(name: Notification.Name(kQuarterValueChanged), object:nil, userInfo: ["value":quaterSlider.value])
    }

    @objc func kitSliderChanged() {
        NotificationCenter.default.post(name: Notification.Name(kKitSliderChanged), object:nil, userInfo: ["value":kitSlider.value])
    }

    @objc func trackSliderChanged() {
        NotificationCenter.default.post(name: Notification.Name(kTrackValueChanged), object:nil, userInfo: ["value":trackSlider.value])
    }

    @objc func speedChanged() {
        NotificationCenter.default.post(name: Notification.Name(kSpeedValueChanged), object:nil, userInfo: ["value":speedSlider.value])
        speedLabel.text = String(format: "Tempo  +/- %.01fx", speedSlider.value)
    }

    @objc func mixChanged() {
        NotificationCenter.default.post(name: Notification.Name(kMixValueChanged), object:nil, userInfo: ["value":mixSlider.value])
    }
}
