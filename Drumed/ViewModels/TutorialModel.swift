//
//  TutorialModel.swift
//  Drumed
//
//  Created by Andrew Donnelly on 02/04/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

class TutorialModel: NSObject {

    var scrollView: UIScrollView!
    var pageControl: UIPageControl!
    var skipButton: UIButton!
    var viewsLayedOut: Bool = false

    fileprivate var parentView: UIView!

    func layoutViews(view: UIView) {
        self.parentView = view
        createScrollView()
        createPageControl()
        createButton()
        viewsLayedOut = true
    }

    func createScrollView() {
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: parentView.frame.width, height: parentView.frame.height-100))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        parentView.addSubview(scrollView)
    }

    func createPageControl() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: parentView.frame.height-150, width: 150, height: 60))
        pageControl.center.x = parentView.center.x
        parentView.addSubview(pageControl)
    }

    func createButton() {
        skipButton = UIButton(type: .custom)
        skipButton.frame = CGRect(x: 0, y: parentView.frame.size.height-80, width: 243, height: 44)
        skipButton.setTitle("Skip", for: .normal)
        skipButton.titleLabel?.font = UIFont(name: "Rubik-Medium", size: 18)
        skipButton.center.x = parentView.center.x
        skipButton.backgroundColor = UIColor(named: "GreyBackground")
        skipButton.dropShadow(cornerRadius: 8.0)
        parentView.addSubview(skipButton)
    }
}
