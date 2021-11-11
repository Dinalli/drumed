//
//  Extensions.swift
//  Drumed
//
//  Created by Andrew Donnelly on 14/08/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import AVKit
import StoreKit

extension AVAudioSession {

    static var isHeadphonesConnected: Bool {
        return sharedInstance().isHeadphonesConnected
    }

    var isHeadphonesConnected: Bool {
        return !currentRoute.outputs.filter { $0.isHeadphones }.isEmpty
    }

}

extension AVAudioSessionPortDescription {
    var isHeadphones: Bool {
        return portType == AVAudioSession.Port.headphones
    }
    var isAirPlay: Bool {
        return portType == AVAudioSession.Port.airPlay
    }
    var isBuiltInSpeaker: Bool {
        return portType == AVAudioSession.Port.builtInSpeaker
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

extension UIViewController {
    /// Shows a toast message to the user with a custom duration
    func showUserToastMessage(message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont(name: "Roboto", size: 18.0)
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds  =  true
            var toastHeight = toastLabel.intrinsicContentSize.height
            var toastWidth = toastLabel.intrinsicContentSize.width + 20
            if toastWidth > self.view.frame.width {
                toastHeight *= 2
                toastWidth = self.view.frame.width-20
                toastLabel.numberOfLines = 0
            }
            toastLabel.frame = CGRect(x: 0, y: self.view.frame.height - 240, width: toastWidth, height: toastHeight + 20)
            toastLabel.center.x = self.view.center.x
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(_ ) in
                toastLabel.removeFromSuperview()
            })
        }
    }

    func showHeadphoneMessage() {
        DispatchQueue.main.async {
            let headphoneImage = UIImageView(image: UIImage(named: "headphone"))
            headphoneImage.frame = CGRect(x: 5, y: 5, width: 64, height: 64)
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont(name: "Roboto", size: 18.0)
            toastLabel.text = "This app is optimised for use with headphones."
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds  =  true
            var toastHeight = toastLabel.intrinsicContentSize.height
            var toastWidth = toastLabel.intrinsicContentSize.width + 20
            if toastWidth > self.view.frame.width-70 {
                toastHeight *= 2
                toastWidth = self.view.frame.width-70
                toastLabel.numberOfLines = 0
            }
            let toastView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 240, width: toastWidth, height: 80))
            toastLabel.frame = CGRect(x: 70, y: 15, width: toastWidth-80, height: toastHeight)

            toastView.backgroundColor = UIColor.black
            toastView.layer.cornerRadius = 10
            toastView.clipsToBounds  =  true
            toastView.center.x = self.view.center.x
            toastView.addSubview(headphoneImage)
            toastView.addSubview(toastLabel)
            self.view.addSubview(toastView)
            UIView.animate(withDuration: 10.0, delay: 0.0, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: {(_ ) in
                toastLabel.removeFromSuperview()
            })
        }
    }

    @objc func showScrollMessage() {
        DispatchQueue.main.async {
            let headphoneImage = UIImageView(image: UIImage(named: "scroll"))
            headphoneImage.frame = CGRect(x: 5, y: 5, width: 64, height: 64)
            let toastLabel = UILabel()
            toastLabel.backgroundColor = UIColor.clear
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = .center
            toastLabel.font = UIFont(name: "Roboto", size: 18.0)
            toastLabel.text = "Scroll up/down left/right to see more loops"
            toastLabel.alpha = 1.0
            toastLabel.numberOfLines = 0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds  =  true
            let toastHeight = toastLabel.intrinsicContentSize.height * 3
            let toastWidth = toastLabel.intrinsicContentSize.width
            let toastView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 240, width: toastWidth+20, height: toastHeight+20))
            toastLabel.frame = CGRect(x: 70, y: 15, width: toastWidth-80, height: toastHeight)
            toastView.backgroundColor = UIColor.black
            toastView.layer.cornerRadius = 10
            toastView.clipsToBounds  =  true
            toastView.center.x = self.view.center.x
            toastView.addSubview(headphoneImage)
            toastView.addSubview(toastLabel)
            self.view.addSubview(toastView)
            UIView.animate(withDuration: 10.0, delay: 0.0, options: .curveEaseOut, animations: {
                toastView.alpha = 0.0
            }, completion: {(_ ) in
                toastLabel.removeFromSuperview()
            })
        }
    }

    func showUserSettingsMessage(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Go to settings...", style: .default, handler: { (_) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showUserAlertMessage(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    func getRecordingsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let recordingsDirectory = documentsDirectory.appendingPathComponent("recordings")
        if !FileManager.default.fileExists(atPath: recordingsDirectory.path) {
            do {
                try FileManager.default.createDirectory(atPath: recordingsDirectory.path, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error.localizedDescription);
            }
        }
        return recordingsDirectory
    }
}

extension UIView {
    func dropShadow(scale: Bool = true, cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.shadowPath =
              UIBezierPath(roundedRect: self.bounds,
              cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 4, height: 4)
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
    }
}

extension UIImageView {

    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2) //instead of let radius = CGRectGetWidth(self.frame) / 2
        self.layer.masksToBounds = true
    }

    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    /// returns the Date as a String given a date format
    func toString( dateFormat format: String ) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

extension Float {

    func secondsToString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
}

extension Float64 {

    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    
    func formattedTimeString() -> String {
        var secs = Int(ceil(self))
        var hours = 0
        var mins = 0

        if secs > TimeConstant.secsPerHour {
            hours = secs / TimeConstant.secsPerHour
            secs -= hours * TimeConstant.secsPerHour
        }

        if secs > TimeConstant.secsPerMin {
            mins = secs / TimeConstant.secsPerMin
            secs -= mins * TimeConstant.secsPerMin
        }

        var formattedString = ""
        if hours > 0 {
            formattedString = "\(String(format: "%02d hours", hours)):"
        }
        formattedString += "\(String(format: "%02d mins ", mins)):\(String(format: "%02d secs", secs))"
        return formattedString
    }
}

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperPurchaseFailNotification = Notification.Name("IAPHelperPurchaseFailNotification")
    static let IAPHelperDownloadCompleteNotification = Notification.Name("IAPHelperDownloadCompleteNotification")
    static let IAPHelperDownloadFailNotification = Notification.Name("IAPHelperDownloadFailNotification")
}

@IBDesignable extension UIButton {

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}

extension TimeInterval {
    func formattedTimeAsPosistionalString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        let formattedString = formatter.string(from: TimeInterval(self))!
        return formattedString
    }
}

extension AVAudioPlayerNode {

    func seekTo(value: Float, audioFile: AVAudioFile, duration: Float) {
        if let nodetime = self.lastRenderTime {
//            let playerTime: AVAudioTime = self.playerTime(forNodeTime: nodetime)!
//            let sampleRate = self.outputFormat(forBus: 0).sampleRate
            let newsampletime = AVAudioFramePosition(Int(44100 * Double(value)))
            let length = duration - value
            let framestoplay = AVAudioFrameCount(Float(44100) * length)
            self.stop()
            print("starting frame \(newsampletime) - \(framestoplay)")
            if framestoplay > 1000 {
                self.scheduleSegment(audioFile, startingFrame: newsampletime, frameCount: framestoplay, at: AVAudioTime(hostTime: UInt64(value)), completionHandler: nil)
            }
        }
        self.play()
    }
}
