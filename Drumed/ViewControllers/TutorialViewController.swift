//
//  TutorialViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 01/04/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

struct Tutorial {
    let title: String
    let text: String
    let image: UIImage
}
class TutorialViewController: UIViewController {

    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var skipButton: UIButton!

    let model = TutorialModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        if !model.viewsLayedOut {
            model.layoutViews(view: self.view)
            scrollView = model.scrollView
            pageControl = model.pageControl
            skipButton = model.skipButton
            skipButton.addTarget(self, action: #selector(skipPressed), for: .touchUpInside)
            createTutorialViews()
        }
    }

    @objc func skipPressed() {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(Notification(name: Notification.Name("kTutorialShown"), object: nil, userInfo: nil))
    }

    func createTutorialViews() {
        scrollView.delegate = self

        var tutorials = [Tutorial]()

        let tutorial = Tutorial(title: "Welcome to Drum-Ed ‘Time To play’", text: "Drum-Ed, Time To Play, is an app based companion to help your drumming and technique.", image: UIImage(named: "Drum-EdLogoMed")!)
        tutorials.append(tutorial)
        let tutorial1 = Tutorial(title: "Play along to Loops", text: "Pre recorded loops allow you to practice techniques", image: UIImage(named: "Microphone")!)
        tutorials.append(tutorial1)
        let tutorial2 = Tutorial(title: "Play along to your own songs", text: "Play along to music from your own Music Library", image: UIImage(named: "Music")!)
        tutorials.append(tutorial2)
        let tutorial3 = Tutorial(title: "Constantly Updated", text: "We will constantly be releasing new loops for your to download and play along to", image: UIImage(named: "Radio-Tower")!)
        tutorials.append(tutorial3)

        pageControl.numberOfPages = tutorials.count

        for index in 0..<tutorials.count {
            var frame = CGRect.zero
            frame.origin.x = scrollView.frame.size.width * CGFloat(index)
            frame.size = scrollView.frame.size
            let tutorial = tutorials[index]
            let tutorialView = TutorialView(frame: frame)
            tutorialView.title = tutorial.title
            tutorialView.text = tutorial.text
            tutorialView.icon = tutorial.image
            self.scrollView.addSubview(tutorialView)
        }

        scrollView.contentSize = CGSize(width: (scrollView.frame.size.width * CGFloat(pageControl.numberOfPages)), height: scrollView.frame.size.height)
    }
}

extension TutorialViewController: UIScrollViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
        if pageControl.currentPage == pageControl.numberOfPages-1 {
            skipButton.setTitle("Get Started", for: .normal)
        } else {
            skipButton.setTitle("Skip", for: .normal)
        }
    }
}
