//
//  DefaultsHelper.swift
//  Drumed
//
//  Created by Andrew Donnelly on 27/01/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

class DefaultsHelper: NSObject {

    func getDefault(for key: String) -> Any? {
        return UserDefaults.standard.value(forKey: key)
    }

    func setDefault(for key: String, with value: Any) {
        UserDefaults.standard.set(value, forKey: key)
    }

    func clearAllDefaults() {
        UserDefaults.standard.removeObject(forKey: "ReverbEffectRow")
        UserDefaults.standard.removeObject(forKey: "Reverb")
        UserDefaults.standard.removeObject(forKey: "Distortion")
        UserDefaults.standard.removeObject(forKey: "DistortionGain")
        UserDefaults.standard.removeObject(forKey: "DistortionEffectRow")
        UserDefaults.standard.removeObject(forKey: "EQSlider0")
        UserDefaults.standard.removeObject(forKey: "EQSlider1")
        UserDefaults.standard.removeObject(forKey: "EQSlider2")
        UserDefaults.standard.removeObject(forKey: "EQSlider3")
        UserDefaults.standard.removeObject(forKey: "EQSlider4")
        UserDefaults.standard.removeObject(forKey: "EQSlider5")
        UserDefaults.standard.removeObject(forKey: "EQSlider6")
        UserDefaults.standard.removeObject(forKey: "DelayValue")
        UserDefaults.standard.removeObject(forKey: "DelayFeedback")
        UserDefaults.standard.removeObject(forKey: "DelayWetDry")
    }
}
