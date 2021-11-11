//
//  DelayView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import CoreAudioKit
import AVFoundation
import AVKit

let kDelayValueChanged = "kDelayValueChanged"
let kFeedbackValueChanged = "kFeedbackValueChanged"
let kDelayWetDryValueChanged = "kDelayWetDryValueChanged"

class DelayView: UIView {

    var delay = AVAudioUnitDelay()

    var wetDrySlider: HorizontalSilder!
    var feedbackSlider: HorizontalSilder!
    var delaySlider: HorizontalSilder!

    var wetDryLabel: UILabel!
    var wetDryMinLabel: UILabel!
    var wetDryMaxLabel: UILabel!
    var wetDryCurrentLabel: UILabel!

    var feedbackLabel: UILabel!
    var feedbackMinLabel: UILabel!
    var feedbackMaxLabel: UILabel!
    var feedbackCurrentLabel: UILabel!

    var delayLabel: UILabel!
    var delayMinLabel: UILabel!
    var delayMaxLabel: UILabel!
    var delayCurrentLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        delaySlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        delaySlider.minimumValue = 0
        delaySlider.maximumValue = 1
        delaySlider.value = 0
        self.addSubview(delaySlider)

        wetDrySlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        wetDrySlider.minimumValue = 0
        wetDrySlider.maximumValue = 100
        wetDrySlider.value = 0
        self.addSubview(wetDrySlider)

        feedbackSlider = HorizontalSilder(frame: CGRect(x: 20, y: 80, width: self.frame.size.width-40, height: 60))
        feedbackSlider.minimumValue = 0
        feedbackSlider.maximumValue = 100
        feedbackSlider.value = 0
        self.addSubview(feedbackSlider)

        delaySlider.addTarget(self, action: #selector(delaySliderValueChanged(_:)), for: .valueChanged)
        wetDrySlider.addTarget(self, action: #selector(wetdryValueChanged(_:)), for: .valueChanged)
        feedbackSlider.addTarget(self, action: #selector(feedbackSliderValueChanged(_:)), for: .valueChanged)

        if let delayValue = defaultsHelper.getDefault(for: "DelayValue") as? Float {
            delaySlider.value = delayValue
            NotificationCenter.default.post(name: Notification.Name(kDelayValueChanged), object:nil, userInfo: ["value":delaySlider.value])
        }
        if let feedbackValue = defaultsHelper.getDefault(for: "DelayFeedback") as? Float {
            feedbackSlider.value = feedbackValue
            NotificationCenter.default.post(name: Notification.Name(kFeedbackValueChanged), object:nil, userInfo: ["value":feedbackSlider.value])
        }
        if let wetdryValue = defaultsHelper.getDefault(for: "DelayWetDry") as? Float {
            wetDrySlider.value = wetdryValue
            NotificationCenter.default.post(name: Notification.Name(kDelayWetDryValueChanged), object:nil, userInfo: ["value":wetDrySlider.value])

        }

        createSliderLabels()
        setAutoLayout()
    }

    fileprivate func createSliderLabels() {
        delayLabel = UILabel()
        delayLabel.text = "Delay"
        delayLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        delayLabel.textColor = UIColor(named: "TextColor")
        delayLabel.textAlignment = .center
        self.addSubview(delayLabel)

        delayMinLabel = UILabel()
        delayMinLabel.text = "0 secs"
        delayMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        delayMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(delayMinLabel)

        delayMaxLabel = UILabel()
        delayMaxLabel.text = "1 sec"
        delayMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        delayMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(delayMaxLabel)

        delayCurrentLabel = UILabel()
        delayCurrentLabel.text = "0.5 secs"
        delayCurrentLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        delayCurrentLabel.textColor = UIColor(named: "TextColor")
        delayCurrentLabel.textAlignment = .center
        self.addSubview(delayCurrentLabel)

        wetDryLabel = UILabel()
        wetDryLabel.text = "WetDry Mix"
        wetDryLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        wetDryLabel.textColor = UIColor(named: "TextColor")
        wetDryLabel.textAlignment = .center
        self.addSubview(wetDryLabel)

        wetDryMinLabel = UILabel()
        wetDryMinLabel.text = "Dry"
        wetDryMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        wetDryMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(wetDryMinLabel)

        wetDryMaxLabel = UILabel()
        wetDryMaxLabel.text = "Wet"
        wetDryMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        wetDryMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(wetDryMaxLabel)

        wetDryCurrentLabel = UILabel()
        wetDryCurrentLabel.text = "Center"
        wetDryCurrentLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        wetDryCurrentLabel.textColor = UIColor(named: "TextColor")
        wetDryCurrentLabel.textAlignment = .center
        self.addSubview(wetDryCurrentLabel)

        feedbackLabel = UILabel()
        feedbackLabel.text = "Feedback"
        feedbackLabel.font = UIFont(name: "Rubik-Bold", size: 20)
        feedbackLabel.textColor = UIColor(named: "TextColor")
        feedbackLabel.textAlignment = .center
        self.addSubview(feedbackLabel)

        feedbackMinLabel = UILabel()
        feedbackMinLabel.text = "0"
        feedbackMinLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        feedbackMinLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(feedbackMinLabel)

        feedbackMaxLabel = UILabel()
        feedbackMaxLabel.text = "100%"
        feedbackMaxLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        feedbackMaxLabel.textColor = UIColor(named: "TextColor")
        self.addSubview(feedbackMaxLabel)

        feedbackCurrentLabel = UILabel()
        feedbackCurrentLabel.text = "50%"
        feedbackCurrentLabel.font = UIFont(name: "Rubik-Medium", size: 16)
        feedbackCurrentLabel.textColor = UIColor(named: "TextColor")
        feedbackCurrentLabel.textAlignment = .center
        self.addSubview(feedbackCurrentLabel)
    }

    func setAutoLayout() {
        delaySlider.translatesAutoresizingMaskIntoConstraints = false
        wetDrySlider.translatesAutoresizingMaskIntoConstraints = false
        feedbackSlider.translatesAutoresizingMaskIntoConstraints = false
        delayLabel.translatesAutoresizingMaskIntoConstraints = false
        delayMinLabel.translatesAutoresizingMaskIntoConstraints = false
        delayMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        delayCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        wetDryLabel.translatesAutoresizingMaskIntoConstraints = false
        wetDryMinLabel.translatesAutoresizingMaskIntoConstraints = false
        wetDryMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        wetDryCurrentLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackMinLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackMaxLabel.translatesAutoresizingMaskIntoConstraints = false
        feedbackCurrentLabel.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraints([
            NSLayoutConstraint(item: delaySlider as Any, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: delaySlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: delaySlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: delayMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: delaySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: delayMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: delaySlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: delayMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: delayLabel as Any, attribute: .top, relatedBy: .equal, toItem: delaySlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: delayLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: delaySlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: delayCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: delaySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: delayCurrentLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: delaySlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: delayMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: delaySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: delayMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: delaySlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: delayMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: wetDrySlider as Any, attribute: .top, relatedBy: .equal, toItem: delaySlider, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: wetDrySlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: wetDrySlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: wetDryMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: wetDrySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: wetDryMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: wetDrySlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: wetDryMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: wetDryLabel as Any, attribute: .top, relatedBy: .equal, toItem: wetDrySlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: wetDryLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: wetDrySlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: wetDryCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: wetDrySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: wetDryCurrentLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: wetDrySlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: wetDryMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: wetDrySlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: wetDryMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: wetDrySlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: wetDryMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),


            NSLayoutConstraint(item: feedbackSlider as Any, attribute: .top, relatedBy: .equal, toItem: wetDrySlider, attribute: .bottom, multiplier: 1, constant: 40),
            NSLayoutConstraint(item: feedbackSlider as Any, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 50),
            NSLayoutConstraint(item: feedbackSlider as Any, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -50),

            NSLayoutConstraint(item: feedbackMinLabel as Any, attribute: .top, relatedBy: .equal, toItem: feedbackSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: feedbackMinLabel as Any, attribute: .left, relatedBy: .equal, toItem: feedbackSlider, attribute: .left, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: feedbackMinLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),

            NSLayoutConstraint(item: feedbackLabel as Any, attribute: .top, relatedBy: .equal, toItem: feedbackSlider, attribute: .top, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: feedbackLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: feedbackSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: feedbackCurrentLabel as Any, attribute: .top, relatedBy: .equal, toItem: feedbackSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: feedbackCurrentLabel as Any, attribute: .centerX, relatedBy: .equal, toItem: feedbackSlider, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: feedbackMaxLabel as Any, attribute: .top, relatedBy: .equal, toItem: feedbackSlider, attribute: .top, multiplier: 1, constant: -10),
            NSLayoutConstraint(item: feedbackMaxLabel as Any, attribute: .left, relatedBy: .equal, toItem: feedbackSlider, attribute: .right, multiplier: 1, constant: -30),
            NSLayoutConstraint(item: feedbackMaxLabel as Any, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 50),
        ])
    }

    @objc func delaySliderValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kDelayValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "DelayValue", with: sender.value)
    }

    @objc func feedbackSliderValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kFeedbackValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "DelayFeedback", with: sender.value)
    }

    @objc func wetdryValueChanged(_ sender: UISlider) {
        NotificationCenter.default.post(name: Notification.Name(kDelayWetDryValueChanged), object:nil, userInfo: ["value":sender.value])
        defaultsHelper.setDefault(for: "DelayWetDry", with: sender.value)
    }
}
