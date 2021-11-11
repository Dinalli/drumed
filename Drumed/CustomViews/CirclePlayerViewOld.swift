//
//  CirclePlayerView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 04/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

class CirclePlayerViewOld: UIView {

    let paragraphStyle = NSMutableParagraphStyle()
    let trackLayer = CAShapeLayer()
    let trackShadowLayer = CAShapeLayer()
    let progressLayer = CAShapeLayer()
    let centerLayer = CAShapeLayer()
    let circleLayer = CAShapeLayer()
    var lastProgressValue: CGFloat = 0.0
    var playHeadImageView: UIImageView!

    var trackNameLabel: UILabel!
    var trackName: String {
        set {
            let textString = NSMutableAttributedString(string: newValue, attributes: [
                NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)!
            ])
            let textRange = NSRange(location: 0, length: textString.length)
            textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
            textString.addAttribute(NSAttributedString.Key.kern, value: 0.58, range: textRange)
            trackNameLabel.attributedText = textString
        }
        get {
            return trackNameLabel.text!
        }
    }

    var artistNameLabel: UILabel!
    var artistName: String {
        set {
            artistNameLabel.text = newValue
            let textString = NSMutableAttributedString(string: newValue, attributes: [
                NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 18)!
            ])
            let textRange = NSRange(location: 0, length: textString.length)
            textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
            artistNameLabel.attributedText = textString
        }
        get {
            return artistNameLabel.text!
        }
    }

    var artistImageView: UIImageView!
    var artistImage: UIImage {
        set {
            artistImageView.image = newValue
        }
        get {
            return artistImageView.image!
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        paragraphStyle.lineSpacing = 1.22

        addArtistImageView()
        addTrackLabel()
        addArtistLabel()

        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: 80, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        let centerPath = UIBezierPath(arcCenter: self.center, radius: 10, startAngle: -CGFloat.pi / 2, endAngle: 2*CGFloat.pi, clockwise: true)
        let borderPath = UIBezierPath(arcCenter: self.center, radius: 75, startAngle: -CGFloat.pi / 2, endAngle: 2*CGFloat.pi, clockwise: true)

        trackShadowLayer.path = circlePath.cgPath
        trackShadowLayer.strokeColor = UIColor.gray.cgColor
        trackShadowLayer.fillColor = UIColor.clear.cgColor
        trackShadowLayer.opacity = 0.3
        trackShadowLayer.lineWidth = 10
        self.layer.addSublayer(trackShadowLayer)

        circleLayer.path = borderPath.cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 10
        self.layer.addSublayer(circleLayer)

        centerLayer.path = centerPath.cgPath
        centerLayer.strokeColor = UIColor.white.cgColor
        centerLayer.fillColor = UIColor.white.cgColor
        centerLayer.lineWidth = 1
        self.layer.addSublayer(centerLayer)

        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = UIColor.darkGray.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.strokeEnd = 0
        progressLayer.lineCap = .round
        self.layer.addSublayer(progressLayer)
    }

    fileprivate func addArtistImageView() {
        artistImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 160, height: 160))
        artistImageView.center = self.center
        artistImageView.contentMode = .scaleAspectFit
        artistImageView.setRounded()
        self.addSubview(artistImageView)
    }

    fileprivate func addArtistLabel() {
        artistNameLabel = UILabel(frame: CGRect(x: 0, y: 180, width: self.frame.width, height: 22))
        artistNameLabel.lineBreakMode = .byWordWrapping
        artistNameLabel.numberOfLines = 0
        artistNameLabel.textColor = UIColor(red:0, green:0.13, blue:0.31, alpha:1)
        artistNameLabel.textAlignment = .center
        let textContent = "My apple music"
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Rubik-Bold", size: 18)!
        ])
        let textRange = NSRange(location: 0, length: textString.length)
        paragraphStyle.lineSpacing = 1.22
        paragraphStyle.alignment = .center
        textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
        artistNameLabel.attributedText = textString
        artistNameLabel.center.x = self.center.x
        self.addSubview(artistNameLabel)
    }

    fileprivate func addTrackLabel() {
        trackNameLabel = UILabel(frame: CGRect(x: 0, y: 200, width: self.frame.width, height: 22))
        trackNameLabel.lineBreakMode = .byWordWrapping
        trackNameLabel.numberOfLines = 0
        trackNameLabel.textColor = UIColor(red:0.48, green:0.53, blue:0.6, alpha:1)
        trackNameLabel.textAlignment = .center
        let textContent = "name of the song"
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)!
        ])
        let textRange = NSRange(location: 0, length: textString.length)
        textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
        textString.addAttribute(NSAttributedString.Key.kern, value: 0.58, range: textRange)
        trackNameLabel.attributedText = textString
        trackNameLabel.center.x = self.center.x
        self.addSubview(trackNameLabel)
    }

    func setProgress(progress: CGFloat) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.duration = 0.5
        basicAnimation.toValue = progress
        basicAnimation.fromValue = lastProgressValue
        basicAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.add(basicAnimation, forKey: "basicAnimation")
        lastProgressValue = progress
    }

    func resetProgress() {
        progressLayer.strokeEnd = 0
    }
}
