//
//  HorizontalSilder.swift
//  Drumed
//
//  Created by Andrew Donnelly on 04/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

class HorizontalSilder: UISlider {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        setThumbImage(UIImage(named: "Knob"), for: .normal)
        setThumbImage(UIImage(named: "Knob"), for: .highlighted)
        setMinimumTrackImage(UIImage(named: "full_Slider"), for: .normal)
        setMaximumTrackImage(UIImage(named: "empty_slider"), for: .normal)
    }
}
