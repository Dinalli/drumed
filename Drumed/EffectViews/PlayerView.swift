//
//  PlayerView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 12/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

let kMixValueChanged = "kMixValueChanged"
let kRateValueChanged = "kRateValueChanged"

class PlayerView: UIView {

    var mixSlider: HorizontalSilder!
    var speedSlider: HorizontalSilder!

    var mixLabel: UILabel!
    var mixMinLabel: UILabel!
    var mixMaxLabel: UILabel!
    var mixCurrentLabel: UILabel!

    var speedLabel: UILabel!
    var speedCurrentLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        speedSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        speedSlider.minimumValue = 0.5
        speedSlider.maximumValue = 1.5
        speedSlider.value = 1
        self.addSubview(speedSlider)

        mixSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        mixSlider.minimumValue = 0
        mixSlider.maximumValue = 100
        mixSlider.value = 50
        self.addSubview(mixSlider)

        speedSlider.addTarget(self, action: #selector(rateValueChanged(_:)), for: .valueChanged)
        mixSlider.addTarget(self, action: #selector(mixValueChanged(_:)), for: .valueChanged)

        createSliderLabels()
        setAutoLayout()
    }

    fileprivate func createSliderLabels() {
        mixLabel = UILabel()
        mixLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        mixLabel.textColor = UIColor(named: "TextColor")
        mixLabel.textAlignment = .center
        mixLabel.text = "Mix"
        self.addSubview(mixLabel)

        mixMinLabel = UILabel()
        mixMinLabel.text = "Mic"
        self.addSubview(mixMinLabel)

        mixMaxLabel = UILabel()
        mixMaxLabel.text = "Music"
        self.addSubview(mixMaxLabel)

        mixCurrentLabel = UILabel()
        mixCurrentLabel.text = "5"
        self.addSubview(mixCurrentLabel)

        speedLabel = UILabel()
        speedLabel.text = "Tempo  +/-"
        speedLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        speedLabel.textColor = UIColor(named: "TextColor")
        speedLabel.textAlignment = .center
        self.addSubview(speedLabel)

        speedCurrentLabel = UILabel()
        speedCurrentLabel.text = "1x"
        self.addSubview(speedCurrentLabel)
    }

    func setAutoLayout() {
        speedSlider.translatesAutoresizingMaskIntoConstraints = false
        mixSlider.translatesAutoresizingMaskIntoConstraints = false
        speedLabel.translatesAutoresizingMaskIntoConstraints = false
        speedCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        mixLabel.translatesAutoresizingMaskIntoConstraints = false
        mixMinLabel.translatesAutoresizingMaskIntoConstraints = false
        mixMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        mixCurrentLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: speedSlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: speedSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: speedSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: speedLabel as Any, attribute: .top, relatedBy: .equal, toItem: speedSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: speedLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: speedSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: speedCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: speedSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: speedCurrentLabel as Any, attribute: .left, relatedBy: .equal, toItem: speedSlider, attribute: .centerX, multiplier: 1, constant: -5),
            NSLayoutConstraint(item: speedCurrentLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 150),

            NSLayoutConstraint(item: mixSlider as Any, attribute: .top, relatedBy: .equal, toItem: speedSlider, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: mixSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: mixSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: mixMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: mixMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: mixSlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: mixMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: mixLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: mixLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: mixSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: mixCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: mixCurrentLabel as Any, attribute: .left, relatedBy: .equal, toItem: mixSlider, attribute: .centerX, multiplier: 1, constant: -5),
            NSLayoutConstraint(item: mixCurrentLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 150),

            NSLayoutConstraint(item: mixMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: mixSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: mixMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: mixSlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: mixMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),
        ])
    }

    @objc func mixValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kMixValueChanged), object:nil, userInfo: ["value":sender.value])
    }

    @objc func rateValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kRateValueChanged), object:nil, userInfo: ["value":sender.value])
        setSpeedLabel()
    }

    func setSpeedLabel() {
        speedCurrentLabel.text = String(format: "%.01fx", speedSlider.value)
        let trackRect = speedSlider.trackRect(forBounds: speedSlider.bounds)
        let thumbRect = speedSlider.thumbRect(forBounds: speedSlider.bounds, trackRect: trackRect, value: speedSlider.value)

        var labelRect = speedCurrentLabel.frame
        labelRect.origin.x = thumbRect.origin.x+50
        speedCurrentLabel.frame = labelRect
    }
}
