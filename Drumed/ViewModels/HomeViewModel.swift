//
//  HomeViewModel.swift
//  Drumed
//
//  Created by Andrew Donnelly on 03/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {

    var headerView: UIView!
    var verticallScrollView: UIScrollView!
    var floatingPlayButton: UIButton!
    var recordingsButton: UIButton!
    var recordingsLabel: UILabel!
    var storeButton: UIButton!
    fileprivate var parentView: UIView!
    var viewsLayedOut: Bool = false

    func layoutViews(view: UIView) {
        self.parentView = view
        createHeaderView()
        addVerticalScrollView()
        addPlayOwnMusicFloatingButton()
        viewsLayedOut = true
    }

    func createHeaderView() {
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 160))
        let backgroundView = UIImageView(frame: headerView.frame)
        backgroundView.image = UIImage(named: "texture_curved")
        backgroundView.contentMode = .scaleAspectFill
        headerView.addSubview(backgroundView)
        let logoView = UIImageView(frame: headerView.frame)
        logoView.image = UIImage(named: "Drum-EdLogoSml")
        logoView.contentMode = .center
        headerView.addSubview(logoView)

        recordingsButton = UIButton(type: .custom)
        recordingsButton.frame = CGRect(x: 0, y: 35,width: 80, height: 40)
        recordingsButton.setImage(UIImage(named: "voicemail"), for: .normal)
        headerView.addSubview(recordingsButton)

        recordingsLabel = UILabel(frame: CGRect(x: 12, y: 63, width: 80, height: 20))
        recordingsLabel.text = "Recordings"
        recordingsLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
        headerView.addSubview(recordingsLabel)

        storeButton = UIButton(type: .custom)
        storeButton.frame = CGRect(x: parentView.frame.size.width-80, y: 35,width: 80, height: 40)
        storeButton.setImage(UIImage(named: "shopping_cart"), for: .normal)
        headerView.addSubview(storeButton)
        parentView.addSubview(headerView)
    }

    func addVerticalScrollView() {
        verticallScrollView = UIScrollView(frame: CGRect(x: 0, y: 160, width: parentView.frame.size.width, height: parentView.frame.size.height-160))
        verticallScrollView.showsHorizontalScrollIndicator = false
        verticallScrollView.showsVerticalScrollIndicator = false
        parentView.addSubview(verticallScrollView)
    }

    func addPlayOwnMusicFloatingButton() {
        floatingPlayButton = UIButton(type: .custom)
        floatingPlayButton.frame = CGRect(x: 0, y: parentView.frame.size.height-70, width: 243, height: 54)
        floatingPlayButton.setTitle("Play along to my music", for: .normal)
        floatingPlayButton.titleLabel?.font = UIFont(name: "Rubik-Medium", size: 18)
        floatingPlayButton.center.x = parentView.center.x
        floatingPlayButton.backgroundColor = UIColor(named: "GreyBackground")
        floatingPlayButton.dropShadow(cornerRadius: 8.0)
        parentView.addSubview(floatingPlayButton)
    }
}
