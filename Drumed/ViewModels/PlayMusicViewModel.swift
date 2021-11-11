//
//  PlayMusicViewModel.swift
//  Drumed
//
//  Created by Andrew Donnelly on 04/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import MediaPlayer
import SwiftUI

class PlayMusicViewModel: NSObject {

    // SwiftUI
    var circlePlayerView = CirclePlayerView()
    var circlePlayerController: UIHostingController<CirclePlayerView>!

    fileprivate var parentView: UIView!

    var buttonBar: UIView!
    var playButton: UIButton!
    var micButton: UIButton!
    var playTitle: UILabel!
    var micTitle: UILabel!

    var effectsScroller: UIScrollView!
    var scrollSnapWidth: CGFloat = 0.0
    var lastOffset:CGFloat = 0.0

    var playControlView: PlayerView!
    var reverbView: ReverbView!
    var distortionView: DistortionView!
    var eqView: EQView!
    var delayView: DelayView!

    func layoutViews(view: UIView) {
        self.parentView = view
        if buttonBar == nil {
            createCirclePlayerView()
            createEffectsScrollerView()
            createPlayAndMicButtons()
            addEffectsToScrollView()
            scrollSnapWidth = self.parentView.frame.size.width
        }
        setAutoLayout()
    }

    func setAutoLayout() {
        circlePlayerController.view.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        effectsScroller.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        playTitle.translatesAutoresizingMaskIntoConstraints = false
        micTitle.translatesAutoresizingMaskIntoConstraints = false

        parentView.addConstraints([
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .topMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .height, relatedBy: .equal, toItem: parentView, attribute: .height, multiplier: 0, constant: 200),
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: effectsScroller as Any, attribute: .top, relatedBy: .equal, toItem: circlePlayerController.view, attribute: .bottom, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .bottom, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: buttonBar as Any, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .height, relatedBy: .equal, toItem: parentView, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: playButton as Any, attribute: .top, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playButton as Any, attribute: .height, relatedBy: .equal, toItem: buttonBar, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: playButton as Any, attribute: .left, relatedBy: .equal, toItem: buttonBar, attribute: .left, multiplier: 1, constant: 40),

            NSLayoutConstraint(item: playTitle as Any, attribute: .bottom, relatedBy: .equal, toItem: playButton, attribute: .top, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: playTitle as Any, attribute: .left, relatedBy: .equal, toItem: buttonBar, attribute: .left, multiplier: 1, constant: 35),

            NSLayoutConstraint(item: micButton as Any, attribute: .top, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: micButton as Any, attribute: .height, relatedBy: .equal, toItem: buttonBar, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: micButton as Any, attribute: .right, relatedBy: .equal, toItem: buttonBar, attribute: .right, multiplier: 1, constant: -40),

            NSLayoutConstraint(item: micTitle as Any, attribute: .bottom, relatedBy: .equal, toItem: micButton, attribute: .top, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: micTitle as Any, attribute: .right, relatedBy: .equal, toItem: buttonBar, attribute: .right, multiplier: 1, constant: -35)
        ])
    }

    fileprivate func createCirclePlayerView() {
        circlePlayerController = UIHostingController(rootView: circlePlayerView)
        circlePlayerController.view.frame = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 200)
        circlePlayerController.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture_full")!)
        parentView.addSubview(circlePlayerController.view)
    }

    fileprivate func createEffectsScrollerView() {
        effectsScroller = UIScrollView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 300))
        effectsScroller.delegate = self
        parentView.addSubview(effectsScroller)
    }

    fileprivate func addEffectsToScrollView() {
        playControlView = PlayerView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        eqView = EQView(frame: CGRect(x: parentView.frame.size.width, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        reverbView = ReverbView(frame: CGRect(x: parentView.frame.size.width * 2, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        distortionView = DistortionView(frame: CGRect(x: parentView.frame.size.width * 3, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        delayView = DelayView(frame: CGRect(x: parentView.frame.size.width * 4, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        effectsScroller.addSubview(playControlView)
        effectsScroller.addSubview(eqView)
        effectsScroller.addSubview(reverbView)
        effectsScroller.addSubview(distortionView)
        effectsScroller.addSubview(delayView)
        effectsScroller.contentSize = CGSize(width: parentView.frame.size.width * 5, height: effectsScroller.frame.size.height)
        effectsScroller.showsVerticalScrollIndicator = false
    }

    fileprivate func createPlayAndMicButtons() {
        buttonBar = UIView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 88))
        buttonBar.backgroundColor = UIColor(patternImage: UIImage(named: "TabBar_Slice")!)

        playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        playButton.center.y = parentView.center.y
        playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        buttonBar.addSubview(playButton)

        playTitle = UILabel()
        playTitle.text = "Play"
        playTitle.textColor = UIColor(named: "MainYellow")
        buttonBar.addSubview(playTitle)

        micButton = UIButton(type: .custom)
        micButton.frame = CGRect(x: 0, y:0, width: 88, height: 88)
        //parentView.center.y = parentView.center.y
        micButton.setImage(UIImage(named: "Mic_Icon"), for: .normal)
        buttonBar.addSubview(micButton)

        micTitle = UILabel()
        micTitle.text = "Mic"
        micTitle.textColor = UIColor(named: "MainYellow")
        buttonBar.addSubview(micTitle)

        parentView.addSubview(buttonBar)
    }

    func updateViewForNewMediaItem(item: MPMediaItem) {
        circlePlayerView.sliderModel.artistName = item.artist != nil ? item.artist! : "No Artist"
        circlePlayerView.sliderModel.trackName = item.title != nil ? item.title! : "No Title"

        if let artworkImage = item.artwork?.image(at: CGSize(width: 200, height: 200)) {
            circlePlayerView.sliderModel.artistImage = Image(uiImage: artworkImage)
        } else  {
            circlePlayerView.sliderModel.artistImage = Image("Drum-EdLogoMed")
        }
    }

    func updateProgressForPlayer(progress: CGFloat) {
        //circlePlayerView.setProgress(progress: progress)
    }

    func resetProgress() {
        //circlePlayerView.resetProgress()
    }

    func setContentOffset(scrollView: UIScrollView) {
        let stopOver = scrollSnapWidth
        var x = round(scrollView.contentOffset.x / stopOver) * stopOver
        x = max(0, min(x, scrollView.contentSize.width - scrollView.frame.width))
        lastOffset = x
        scrollView.setContentOffset(CGPoint(x: x, y: scrollView.contentOffset.y), animated: true)
        scrollView.isScrollEnabled = true
    }
}

extension PlayMusicViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x > lastOffset + scrollSnapWidth {
            scrollView.isScrollEnabled = false
        } else if scrollView.contentOffset.x < lastOffset - scrollSnapWidth {
            scrollView.isScrollEnabled = false
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        setContentOffset(scrollView: scrollView)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        setContentOffset(scrollView: scrollView)
    }
}
