//
//  SectionView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 03/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

class SectionView: UIView {
    var sectionTitle: String!
    var loops: [DrumLoop]!

    func layoutSectionView() {
        let sectionTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: self.frame.size.width, height: 40))
        sectionTitleLabel.text = sectionTitle
        sectionTitleLabel.textAlignment = .left
        sectionTitleLabel.font = CTFontCreateWithName("Rubik-Bold" as CFString, 22.0, nil)
        self.addSubview(sectionTitleLabel)

        let sectionScrollView = UIScrollView(frame: CGRect(x: 0, y: 50, width: self.frame.size.width, height: 210))
        sectionScrollView.showsVerticalScrollIndicator = false
        sectionScrollView.showsHorizontalScrollIndicator = false
        self.addSubview(sectionScrollView)

        var loopPosX = 10
        for drumLoop in loops {
            let loopContentView = ContentView(frame: CGRect(x: loopPosX, y: 0, width: 200, height: 200))
            loopContentView.drumLoop = drumLoop
            loopContentView.setUpLayout()
            sectionScrollView.addSubview(loopContentView)
            loopPosX += 210
        }
        sectionScrollView.contentSize = CGSize(width: loopPosX, height: 200)
    }
}
