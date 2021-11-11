//
//  JamViewModel.swift
//  Drumed
//
//  Created by Andrew Donnelly on 10/12/2019.
//  Copyright © 2019 Andrew Donnelly. All rights reserved.
//

import UIKit
import SwiftUI

class JamViewModel: NSObject {

    // SwiftUI
    var circlePlayerView = CirclePlayerView()
    var circlePlayerController: UIHostingController<CirclePlayerView>!
    
    fileprivate var parentView: UIView!

    var buttonBar: UIView!
    var playButton: UIButton!
    var micButton: UIButton!
    var recButton: UIButton!
    var playTitle: UILabel!
    var micTitle: UILabel!
    var recTitle: UILabel!

    var effectsScroller: UIScrollView!
    var scrollSnapWidth: CGFloat = 0.0
    var lastOffset:CGFloat = 0.0

    var instumentView: InstrumentPlayView!
    var reverbView: ReverbView!
    var distortionView: DistortionView!
    var eqView: EQView!
    var delayView: DelayView!

    var slider = UISlider()
    var ffwdButton = UIButton()
    var rwdButton  = UIButton()

    func layoutViews(view: UIView) {
        self.parentView = view
        if buttonBar == nil {
            createCirclePlayerView()
            createScrubber()
            createEffectsScrollerView()
            createButtonToolBarView()
            addEffectsToScrollView()
            scrollSnapWidth = self.parentView.frame.size.width
        }
        setAutoLayout()
    }

    func setAutoLayout() {
        circlePlayerController.view.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        playButton.translatesAutoresizingMaskIntoConstraints = false
        micButton.translatesAutoresizingMaskIntoConstraints = false
        recButton.translatesAutoresizingMaskIntoConstraints = false
        effectsScroller.translatesAutoresizingMaskIntoConstraints = false
        playTitle.translatesAutoresizingMaskIntoConstraints = false
        micTitle.translatesAutoresizingMaskIntoConstraints = false
        recTitle.translatesAutoresizingMaskIntoConstraints = false

        slider.translatesAutoresizingMaskIntoConstraints = false

        parentView.addConstraints([
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .topMargin, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .height, relatedBy: .equal, toItem: parentView, attribute: .height, multiplier: 0, constant: 150),
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: circlePlayerController.view as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: slider as Any, attribute: .top, relatedBy: .equal, toItem: circlePlayerController.view, attribute: .bottom, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: slider as Any, attribute: .bottom, relatedBy: .equal, toItem: effectsScroller, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slider as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: slider as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: effectsScroller as Any, attribute: .top, relatedBy: .equal, toItem: slider, attribute: .bottom, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .bottom, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: effectsScroller as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: playButton as Any, attribute: .top, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: playButton as Any, attribute: .height, relatedBy: .equal, toItem: buttonBar, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: playButton as Any, attribute: .left, relatedBy: .equal, toItem: buttonBar, attribute: .left, multiplier: 1, constant: 40),

            NSLayoutConstraint(item: playTitle as Any, attribute: .bottom, relatedBy: .equal, toItem: playButton, attribute: .top, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: playTitle as Any, attribute: .left, relatedBy: .equal, toItem: buttonBar, attribute: .left, multiplier: 1, constant: 40),

            NSLayoutConstraint(item: micButton as Any, attribute: .top, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: micButton as Any, attribute: .height, relatedBy: .equal, toItem: buttonBar, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: micButton as Any, attribute: .width, relatedBy: .equal, toItem: buttonBar, attribute: .width, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: micButton as Any, attribute: .centerX, relatedBy: .equal, toItem: buttonBar, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: micTitle as Any, attribute: .bottom, relatedBy: .equal, toItem: micButton, attribute: .top, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: micTitle as Any, attribute: .centerX, relatedBy: .equal, toItem: buttonBar, attribute: .centerX, multiplier: 1, constant: 0),

            NSLayoutConstraint(item: recButton as Any, attribute: .top, relatedBy: .equal, toItem: buttonBar, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: recButton as Any, attribute: .height, relatedBy: .equal, toItem: buttonBar, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: recButton as Any, attribute: .right, relatedBy: .equal, toItem: buttonBar, attribute: .right, multiplier: 1, constant: -40),

            NSLayoutConstraint(item: recTitle as Any, attribute: .bottom, relatedBy: .equal, toItem: recButton, attribute: .top, multiplier: 1, constant: 25),
            NSLayoutConstraint(item: recTitle as Any, attribute: .right, relatedBy: .equal, toItem: buttonBar, attribute: .right, multiplier: 1, constant: -45),

            NSLayoutConstraint(item: buttonBar as Any, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .height, relatedBy: .equal, toItem: parentView, attribute: .height, multiplier: 0, constant: 88),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: buttonBar as Any, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1, constant: 0)
        ])
    }

    fileprivate func createCirclePlayerView() {
        circlePlayerController = UIHostingController(rootView: circlePlayerView)
        circlePlayerController.view.frame = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 200)
        circlePlayerController.view.backgroundColor = UIColor(patternImage: UIImage(named: "texture_full")!)
        parentView.addSubview(circlePlayerController.view)
    }

    fileprivate func createScrubber() {
        print("CREATE SCRUB")
        slider = UISlider()
        slider.frame = CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 10)
        slider.isContinuous = false
        slider.setThumbImage(UIImage(named: "Knob"), for: .normal)
        slider.setThumbImage(UIImage(named: "Knob"), for: .highlighted)
        slider.setMinimumTrackImage(UIImage(named: "full_Slider"), for: .normal)
        slider.setMaximumTrackImage(UIImage(named: "empty_slider"), for: .normal)
        parentView.addSubview(slider)
    }

    fileprivate func createEffectsScrollerView() {
        effectsScroller = UIScrollView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 300))
        effectsScroller.delegate = self
        parentView.addSubview(effectsScroller)
    }

    fileprivate func addEffectsToScrollView() {
        instumentView = InstrumentPlayView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        eqView = EQView(frame: CGRect(x: parentView.frame.size.width, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        reverbView = ReverbView(frame: CGRect(x: parentView.frame.size.width * 2, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        distortionView = DistortionView(frame: CGRect(x: parentView.frame.size.width * 3, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        delayView = DelayView(frame: CGRect(x: parentView.frame.size.width * 4, y: 0, width: parentView.frame.size.width, height: effectsScroller.frame.size.height))
        effectsScroller.addSubview(instumentView)
        effectsScroller.addSubview(eqView)
        effectsScroller.addSubview(reverbView)
        effectsScroller.addSubview(distortionView)
        effectsScroller.addSubview(delayView)
        effectsScroller.contentSize = CGSize(width: parentView.frame.size.width * 5, height: effectsScroller.frame.size.height)
        effectsScroller.showsVerticalScrollIndicator = false
    }

    fileprivate func createButtonToolBarView() {
        buttonBar = UIView(frame: CGRect(x: 0, y: 0, width: parentView.frame.size.width, height: 88))
        buttonBar.backgroundColor = UIColor(patternImage: UIImage(named: "TabBar_Slice")!)

        playTitle = UILabel()
        playTitle.text = "Play"
        playTitle.textColor = UIColor(named: "MainYellow")
        buttonBar.addSubview(playTitle)

        playButton = UIButton(type: .custom)
        playButton.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        playButton.setImage(UIImage(named: "Play_Button_off"), for: .normal)
        buttonBar.addSubview(playButton)

        micTitle = UILabel()
        micTitle.text = "Mic"
        micTitle.textColor = UIColor(named: "MainYellow")
        buttonBar.addSubview(micTitle)

        micButton = UIButton(type: .custom)
        micButton.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        micButton.setImage(UIImage(named: "Mic_Icon"), for: .normal)
        buttonBar.addSubview(micButton)

        recTitle = UILabel()
        recTitle.text = "Rec"
        recTitle.textColor = UIColor(named: "MainYellow")
        buttonBar.addSubview(recTitle)

        recButton = UIButton(type: .custom)
        recButton.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        recButton.setImage(UIImage(named: "Rec_Icon"), for: .normal)
        buttonBar.addSubview(recButton)

        parentView.addSubview(buttonBar)
    }

    func updateViewForNewDrumLoop(loop: DrumLoop) {
        circlePlayerView.sliderModel.artistName = loop.Section
        circlePlayerView.sliderModel.trackName = loop.LoopName
        circlePlayerView.sliderModel.artistImage = Image("Drum-EdLogoMed")
    }

    func setContentOffset(scrollView: UIScrollView) {
        let stopOver = scrollSnapWidth
        var x = round(scrollView.contentOffset.x / stopOver) * stopOver
        x = max(0, min(x, scrollView.contentSize.width - scrollView.frame.width))
        lastOffset = x
        scrollView.setContentOffset(CGPoint(x: x, y: scrollView.contentOffset.y), animated: true)
        scrollView.isScrollEnabled = true
    }

    func updateProgressForPlayer(progress: CGFloat) {
        //circlePlayerView.setProgress(progress: progress)
    }

    func resetProgress() {
        //circlePlayerView.resetProgress()
    }
}

extension JamViewModel: UIScrollViewDelegate {
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
