//
//  TutorialView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 01/04/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

class TutorialView: UIView {

    let paragraphStyle = NSMutableParagraphStyle()
    var titleLabel: UILabel!
    var title: String {
        set {
            let textString = NSMutableAttributedString(string: newValue, attributes: [
                NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 36)!
            ])
            let textRange = NSRange(location: 0, length: textString.length)
            textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
            textString.addAttribute(NSAttributedString.Key.kern, value: 0.58, range: textRange)
            titleLabel.attributedText = textString
        }
        get {
            return titleLabel.text!
        }
    }

    var textLabel: UILabel!
    var text: String {
        set {
            textLabel.text = newValue
            let textString = NSMutableAttributedString(string: newValue, attributes: [
                NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 18)!
            ])
            let textRange = NSRange(location: 0, length: textString.length)
            textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
            textLabel.attributedText = textString
        }
        get {
            return textLabel.text!
        }
    }

    var iconView: UIImageView!
    var icon: UIImage {
        set {
            iconView.image = newValue
        }
        get {
            return iconView.image!
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setupViews() {
        self.backgroundColor = UIColor(named: "GreyBackground")
        paragraphStyle.lineSpacing = 1.22
        addTitleLabel()
        addTextLabel()
        addImageView()
    }

    fileprivate func addTitleLabel() {
        titleLabel = UILabel(frame: CGRect(x: 0, y: 120, width: self.frame.width, height: 40))
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = UIColor(named: "MainYellow")
        titleLabel.textAlignment = .center
        let textContent = "Welcome"
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Rubik-Bold", size: 36)!
        ])
        let textRange = NSRange(location: 0, length: textString.length)
        paragraphStyle.lineSpacing = 1.22
        paragraphStyle.alignment = .center
        textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
        titleLabel.attributedText = textString
        titleLabel.center.x = self.frame.width/2
        self.addSubview(titleLabel)
    }

    fileprivate func addTextLabel() {
        textLabel = UILabel(frame: CGRect(x: 20, y: 190, width: self.frame.width-40, height: 80))
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.numberOfLines = 0
        textLabel.textColor = UIColor(named: "MainYellow")
        textLabel.textAlignment = .center
        let textContent = "some text about the app and how it functions"
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)!
        ])
        let textRange = NSRange(location: 0, length: textString.length)
        textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
        textString.addAttribute(NSAttributedString.Key.kern, value: 0.58, range: textRange)
        textLabel.attributedText = textString
        textLabel.center.x = self.frame.width/2
        self.addSubview(textLabel)
    }

    fileprivate func addImageView() {
        iconView = UIImageView(frame: CGRect(x: 0, y: 240, width: self.frame.width/3, height: self.frame.height/3))
        iconView.center.x = self.frame.width/2
        iconView.contentMode = .scaleAspectFit
        self.addSubview(iconView)
    }
}
