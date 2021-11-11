//
//  ContentView.swift
//  Drumed
//
//  Created by Andrew Donnelly on 03/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

class ContentView: UIView {

    var drumLoop: DrumLoop!
    var backgroundImage: UIImage!
    var lockView: UIImageView!
    var downloadView: UIButton!
    let storeKitHelper = StoreKitHelper()
    var progressView: UIProgressView!

    func setUpLayout() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeToDownloadIcon), name: Notification.Name("kLoopDownloaded"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(removeLock), name: Notification.Name("kPurchaseCompleted"), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(removeLock), name: Notification.Name("kRestorePurchaseCompleted"), object: nil)

        let backgroundView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        if drumLoop.CustomIconUrl == "" {
            backgroundView.image = UIImage(named: drumLoop.Icon)
        } else {
            if let imageURL = URL.init(string: drumLoop.CustomIconUrl) {
                backgroundView.load(url: imageURL)
            } else {
                backgroundView.image = UIImage(named: drumLoop.Icon)
            }
        }
        backgroundView.contentMode = .center
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 30
        self.addSubview(backgroundView)

        let textLayer = UILabel(frame: CGRect(x: 10, y: 130, width: 108, height: 22))
        textLayer.lineBreakMode = .byWordWrapping
        textLayer.numberOfLines = 0
        textLayer.textColor = UIColor(named: "MainYellow")
        let textContent = drumLoop.LoopName
        let font = UIFont(name: "Rubik-Bold", size: 22)
        let textString = NSMutableAttributedString(string: textContent, attributes: [
            NSAttributedString.Key.font: font!
        ])
        let textRange = NSRange(location: 0, length: textString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.22
        textString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: textRange)
        textLayer.attributedText = textString
        textLayer.sizeToFit()
        self.addSubview(textLayer)

        let bpmLabel = UILabel(frame: CGRect(x: 10, y: 155, width: 108, height: 22))
        bpmLabel.lineBreakMode = .byWordWrapping
        bpmLabel.numberOfLines = 0
        bpmLabel.textColor = UIColor(named: "MainYellow")
        let bpmTextContent = drumLoop.BPM
        let bpmfont = UIFont(name: "Rubik", size: 14)
        let bpmtextString = NSMutableAttributedString(string: bpmTextContent, attributes: [
            NSAttributedString.Key.font: bpmfont!
        ])
        let bpmtextRange = NSRange(location: 0, length: bpmtextString.length)
        let bpmparagraphStyle = NSMutableParagraphStyle()
        bpmparagraphStyle.lineSpacing = 1.22
        bpmtextString.addAttribute(NSAttributedString.Key.paragraphStyle, value:bpmparagraphStyle, range: bpmtextRange)
        bpmLabel.attributedText = bpmtextString
        bpmLabel.sizeToFit()
        self.addSubview(bpmLabel)

        lockView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        lockView.backgroundColor = .clear
        lockView.image = UIImage(named: "Lock")
        lockView.contentMode = .center

        downloadView = UIButton(type: .custom)
        downloadView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width/4, height: self.frame.size.height/4)
        downloadView.backgroundColor = .clear
        downloadView.setImage(UIImage(named: "download"), for: .normal)
        downloadView.contentMode = .center
        downloadView.addTarget(self, action: #selector(downloadTrack(_:)), for: .touchUpInside)
        if drumLoop.DownloadUrls.count > 0 {
            if !downloadHelper.haveTheFilesBeenDownloaded(drumLoop: drumLoop) {
                self.addSubview(downloadView)
            }
        }

        progressView = UIProgressView(frame: CGRect(x: 25, y: self.frame.size.height-15, width: self.frame.size.width-50, height: 30))
        progressView.isHidden = false
        self.addSubview(progressView)

        if drumLoop.DownloadUrls.count > 0 {
            self.addSubview(lockView)
            if drumLoop.SubscriptionRequired {
                lockView.isHidden = false
            } else  {
                lockView.isHidden = true
            }
        }

        self.dropShadow(cornerRadius: 30.0)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
    }

    @objc func downloadTrack(_ sender: UIButton) {
        NotificationCenter.default.post(Notification(name: Notification.Name("kLoopDownload"), object: nil, userInfo: ["selectedLoop": drumLoop!, "contentView": self]))
    }

    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        NotificationCenter.default.post(Notification(name: Notification.Name("kLoopSelected"), object: nil, userInfo: ["selectedLoop": drumLoop!, "contentView": self]))
    }

    @objc func changeToDownloadIcon(notification: NSNotification) {
        if notification.userInfo != nil {
            guard let notificationDrumLoop: DrumLoop = notification.userInfo!["selectedLoop"] as? DrumLoop else { return }
            if self.drumLoop.LoopName == notificationDrumLoop.LoopName {
                DispatchQueue.main.async {
                        self.downloadView.isHidden = true
                }
            }
        }
    }

    @objc func removeLock() {
        DispatchQueue.main.async {
            self.lockView.isHidden = true
        }
    }
}
