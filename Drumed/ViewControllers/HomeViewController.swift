//
//  LoopsCollectionViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 14/08/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import AVKit

private let reuseIdentifier = "loopCell"

class HomeViewController: UIViewController {

    let storeKitHelper = StoreKitHelper()
    let homeModel = HomeViewModel()

    var verticallScrollView: UIScrollView!
    var floatingButton: UIButton!
    var recordingButton: UIButton!
    var storeButton: UIButton!

    var playerViewController = AVPlayerViewController()
    var videoTimer: Timer!
    var currentSelectedLoop: DrumLoop!
    var currentlySelectedContentView: ContentView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playLoopPressed), name: Notification.Name("kLoopSelected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadLoop), name: Notification.Name("kLoopDownload"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoops), name: Notification.Name("kUpdateLoops"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showScrollMessage), name: Notification.Name("kTutorialShown"), object: nil)
        if defaultsHelper.getDefault(for: "firstLoad") == nil {
            performSegue(withIdentifier: "showTutorialSegue", sender: self)
            defaultsHelper.setDefault(for: "firstLoad", with: true)
        }
        storeKitHelper.delegate = self
        downloadHelper.delegate = self
    }

    override func viewWillLayoutSubviews() {
        if !homeModel.viewsLayedOut {
            super.viewWillLayoutSubviews()
            homeModel.layoutViews(view: self.view)
            self.verticallScrollView = homeModel.verticallScrollView
            self.floatingButton = homeModel.floatingPlayButton
            self.recordingButton = homeModel.recordingsButton
            self.storeButton = homeModel.storeButton
            floatingButton.addTarget(self, action: #selector(playMyMusicPressed), for: .touchUpInside)
            recordingButton.addTarget(self, action: #selector(showRecordings), for: .touchUpInside)
            storeButton.addTarget(self, action: #selector(showStore), for: .touchUpInside)
        }
    }

    @objc func playMyMusicPressed() {
        performSegue(withIdentifier: "playMusicSegue", sender: self)
    }

    @objc func showRecordings() {
        performSegue(withIdentifier: "showRecordingsSegue", sender: self)
    }

    @objc func showStore() {
        // Add deldgate
        performSegue(withIdentifier: "showStoreSegue", sender: self)
    }

    @objc func downloadLoop(notification: NSNotification) {
        if notification.userInfo != nil {
            guard let selectedLoop: DrumLoop = notification.userInfo!["selectedLoop"] as? DrumLoop else { return }
            currentSelectedLoop = selectedLoop
            downloadHelper.downloadContent(drumLoop: selectedLoop)
        }
    }

    @objc func playLoopPressed(notification: NSNotification) {
        if notification.userInfo != nil {
            guard let selectedLoop: DrumLoop = notification.userInfo!["selectedLoop"] as? DrumLoop else { return }
            currentSelectedLoop = selectedLoop
            if currentSelectedLoop.SubscriptionRequired && !storeKitHelper.isSubscribed() {
                if storeKitHelper.canMakePurchase() {
                    // TODO : Replace this with alert then segue to purchase
//                    let alert = UIAlertController(title: "Subscription Required.", message: "To play along to these loops you will need to subscribe. Would you like to see the subscription options.", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Yes Please", style: .default, handler: { (action) in
                        self.showStore()
//                    }))
//                    alert.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
                } else {
                    showUserToastMessage(message: "Unfortuntaly you are not permited to make purchases on this account.", duration: 5.0)
                }
            } else {
                if storeKitHelper.isSubscribed() && !downloadHelper.haveTheFilesBeenDownloaded(drumLoop: currentSelectedLoop) {
                    /// Download the loop files
                    let alert = UIAlertController(title: "Download Loop", message: "Are you sure you wish to download this loop?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Yes Please", style: .default, handler: { (action) in
                        downloadHelper.downloadContent(drumLoop: self.currentSelectedLoop)
                    }))
                    alert.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if downloadHelper.haveTheFilesBeenDownloaded(drumLoop: currentSelectedLoop) || Bundle.main.url(forResource: currentSelectedLoop.Files[0], withExtension: "") != nil {
                        performSegue(withIdentifier: "playLoopSegue", sender: self)
                    } else {
                        let alert = UIAlertController(title: "Download Loop", message: "Are you sure you wish to download this loop?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes Please", style: .default, handler: { (action) in
                            downloadHelper.downloadContent(drumLoop: self.currentSelectedLoop)
                        }))
                        alert.addAction(UIAlertAction(title: "No Thanks", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
            if let contentView = notification.userInfo!["contentView"] as? ContentView {
                currentlySelectedContentView = contentView
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        showScrollMessage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutContent()
        storeKitHelper.getIAPProducts { (success, products) in
            // check if we need to remove the locks
            if self.storeKitHelper.isSubscribed() {
                NotificationCenter.default.post(Notification(name: Notification.Name("kPurchaseCompleted"), object: nil, userInfo: nil))
                self.storeKitHelper.restorePurchases()
            }
        }
    }

    @objc func updateLoops() {
        self.showUserToastMessage(message: "Downloading new config.", duration: 2.5)
        layoutContent()
        if storeKitHelper.products != nil {
            if storeKitHelper.products.count > 0 {
                self.storeKitHelper.restorePurchases()
            }
        }
    }

    func layoutContent() {
        if verticallScrollView != nil {
            DispatchQueue.main.async {
                _ = self.verticallScrollView.subviews.filter { $0 is SectionView }.map { $0.removeFromSuperview() }
                if configHelper.getSections().count > 0 {
                    self.addSectionsToScrollView()
                } else {
                    self.showUserToastMessage(message: "No content is available at this time.", duration: 2.5)
                }
            }
        }
    }

    func addSectionsToScrollView() {
        var sectionPosY = 0.0
        for sectionName in configHelper.getSections() {
            let loopsInSection = configHelper.getForSection(sectionName: sectionName)
            let sectionView = SectionView(frame: CGRect(x: 0.0, y: CGFloat(sectionPosY), width: self.verticallScrollView.frame.size.width, height: 250.0))
            sectionView.sectionTitle = sectionName
            sectionView.loops = loopsInSection
            sectionView.layoutSectionView()
            verticallScrollView.addSubview(sectionView)
            sectionPosY += 260.0
        }
        verticallScrollView.contentSize = CGSize(width: self.verticallScrollView.frame.size.width, height: CGFloat(sectionPosY))
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "playLoopSegue" {
            guard let destinationVC = segue.destination as? JamViewController else { return }
            destinationVC.drumLoop = currentSelectedLoop
        }
    }
}

extension HomeViewController: StoreKitHelperDelegate {

    func storeKitHelperPurchaseRestoredFail() {
        let alert = UIAlertController(title: "Oops something went wrong.", message: "We could not complete your purchase, please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func storeKitHelperPurchaseRestored() {
        if storeKitHelper.isSubscribed() {
            NotificationCenter.default.post(Notification(name: Notification.Name("kPurchaseCompleted"), object: nil, userInfo: nil))
        }
    }

    func storeKitHelperPurchaseFail() {
        let alert = UIAlertController(title: "Oops something went wrong.", message: "We could not complete your purchase, please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func storeKitHelperPurchaseComplete() {
        NotificationCenter.default.post(Notification(name: Notification.Name("kPurchaseCompleted"), object: nil, userInfo: nil))
    }
}

extension HomeViewController: DownloadHelperDelegate {
    func DownloadComplete() {
        // Remove download Icon
        NotificationCenter.default.post(Notification(name: Notification.Name("kLoopDownloaded"), object: nil, userInfo: ["selectedLoop": currentSelectedLoop!]))
    }

    func DownloadFailed() {
        let alert = UIAlertController(title: "Oops something went wrong.", message: "We could not download the loops, please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
