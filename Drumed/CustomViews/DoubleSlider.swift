//
//  DoubleSlider.swift
//  Drumed
//
//  Created by Andrew Donnelly on 22/08/2021.
//  Copyright © 2021 Andrew Donnelly. All rights reserved.
//

//  Created by Ivan Shokurov on 8/12/20.
// This a custom slider (by UISlider)
// with two thumbs instead of default one.

import UIKit
import Foundation

//swiftlint:disable:next type_body_length
public final class DoubledSlider: UIControl//  Created by Ivan Shokurov on 8/12/20.
// This a custom slider (by UISlider)
// with two thumbs instead of default one.

import UIKit

//swiftlint:disable:next type_body_length
public final class DoubledSlider: UIControl, ViewProgrammatically {

    // MARK: - UI

    private lazy var track = UIView()
    private lazy var activeTrack = UIView()
    private lazy var leftThumb = UIImageView()
    private lazy var rightThumb = UIImageView()

    // MARK: - Initialization

    public convenience init(minimumValue: Float = .zero, maximumValue: Float = .zero) {
        self.init()
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
    }

    private override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.addSubviews()
        self.setupSubviews()
        self.makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    public var minimumValue: Float = .zero
    public var maximumValue: Float = .zero

    public var values: (minimum: Float, maximum: Float) {
        get { return (self.minimumValueNow, self.maximumValueNow) }
        set {
            var newMin: Float = .zero; var newMax: Float = .zero
            if newValue.0 <= .zero {
                newMin = self.minimumValue
            }
            if newValue.0 <= self.minimumValue {
                newMin = self.minimumValue
            }
            if newValue.0 > newValue.1 {
                newMin = newValue.1
            }
            if newValue.1 <= .zero {
                newMax = self.minimumValue
            }
            if newValue.1 >= self.maximumValue {
                newMax = self.maximumValue
            }
            if newValue.1 < newValue.0 {
                newMax = newValue.0
            }
            self.minimumValueNow = newMin
            self.maximumValueNow = newMax
        }
    }

    // MARK: - Private API

    private var minimumValueNow: Float = .zero
    private var maximumValueNow: Float = .zero

    private func updateValues(_ completion: @escaping () -> Void) {
        self.minimumValueNow = self.newMinimalValue
        self.maximumValueNow = self.newMaximumValue
        let originXDifference = abs(self.rightThumb.frame.origin.x - self.leftThumb.frame.origin.x)
        if originXDifference < 20 {
            self.minimumValueNow = self.maximumValueNow
        }
        completion()
    }

    private var newMinimalValue: Float {
        let leftThumbOriginX = self.leftThumbConstraint.constant
        let halfOfThumbWidth = self.leftThumb.frame.size.width / 2
        let distancePassed = leftThumbOriginX + halfOfThumbWidth
        let totalDistance = self.track.frame.size.width
        let distancePassedFraction = distancePassed / totalDistance
        if leftThumbOriginX < 3 {
            return self.minimumValue
        }
        if totalDistance - (leftThumbOriginX + self.leftThumb.frame.size.width) < 3 {
            return self.maximumValue
        }
        let newValue: Float = {
            let difference = self.maximumValue - self.minimumValue
            let addingValue = Float(distancePassedFraction) * difference
            return self.minimumValue + addingValue
        }()
        return newValue
    }

    private var newMaximumValue: Float {
        let constraintConstant = abs(self.rightThumbConstraint.constant)
        let distancePassed = constraintConstant + self.leftThumb.frame.size.width / 2
        let totalDistance = self.track.frame.size.width
        let distancePassedFraction = distancePassed / totalDistance
        if constraintConstant < 3 {
            return self.maximumValue
        }
        if totalDistance - (self.rightThumb.frame.size.width + constraintConstant) < 3 {
            return self.minimumValue
        }
        let newValue: Float = {
            let difference = self.maximumValue - self.minimumValue
            let addingValue = difference * Float(distancePassedFraction)
            return self.maximumValue - addingValue
        }()
        return newValue
    }

    // MARK: - View Programmatically

    public func addSubviews() {
        self.addSubview(self.track)
        self.track.addSubview(self.activeTrack)
        self.addSubview(self.leftThumb)
        self.addSubview(self.rightThumb)
    }

    public func setupSubviews() {
        self.setupItself()
        self.setupTrack()
        self.setupActiveTrack()
        self.setupThumbs()
    }

    public func makeConstraints() {
        defer {
            [self.leftThumb, self.rightThumb].forEach { self.bringSubviewToFront($0) }
        }
        self.makeConstraintsForTrack()
        self.makeConstraintsForThumbs()
        self.makeConstraintsForActiveTrack()
    }

    // MARK: - Setups

    private func setupItself() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTrack() {
        self.track.layer.masksToBounds = true
        self.track.layer.cornerRadius = 1.5
        self.track.backgroundColor = A.superLightGrayBackground.color
        self.track.clipsToBounds = true
    }

    private func setupActiveTrack() {
        self.activeTrack.backgroundColor = A.purpleishBlue.color
    }

    private func setupThumbs() {
        [self.leftThumb, self.rightThumb].forEach {
            $0.image = A.sliderThumb.image
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragThumb(using:)))
            $0.addGestureRecognizer(gesture)
        }
        self.leftThumb.tag = 1
        self.rightThumb.tag = 2
    }

    @objc private func dragThumb(using gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            if [1, 2].contains(view.tag) { self.bringSubviewToFront(view) }
        case .changed:
            self.handleDragging(view, withTranslation: translation)
        case .ended:
            self.handleEndedDragging(view)
        default:
            break
        }
    }

    private func handleDragging(_ view: UIView, withTranslation translation: CGPoint) {
        switch view.tag {
        case 1:
            self.handleDraggingLeftThumb(view, withTranslation: translation)
        case 2:
            self.handleDraggingRightThumb(view, withTranslation: translation)
        default:
            break
        }
    }

    private func handleDraggingLeftThumb(_ thumb: UIView, withTranslation translation: CGPoint) {
        let newConstant = translation.x + self.leftThumbConstraintLastConstant
        guard newConstant > -0.001 else {
            self.leftThumbConstraint.constant = .zero
            self.leftActiveTrackConstraint.constant = .zero
            self.updateValues {
                self.sendActions(for: .valueChanged)
            }
            return
        }
        if self.thumbesInOnePlace(byDraggingThumb: thumb) && translation.x > .zero { return }
        self.leftThumbConstraint.constant = newConstant
        self.leftActiveTrackConstraint.constant = newConstant
        self.updateValues {
            self.sendActions(for: .valueChanged)
        }
    }

    private func handleDraggingRightThumb(_ thumb: UIView, withTranslation translation: CGPoint) {
        let newConstant = translation.x + self.rightThumbConstraintLastConstant
        guard newConstant < 0.001 else {
            self.rightThumbConstraint.constant = .zero
            self.rightActiveTrackConstraint.constant = .zero
            self.updateValues {
                self.sendActions(for: .valueChanged)
            }
            return
        }
        if self.thumbesInOnePlace(byDraggingThumb: thumb) && translation.x < .zero { return }
        self.rightThumbConstraint.constant = newConstant
        self.rightActiveTrackConstraint.constant = newConstant
        self.updateValues {
            self.sendActions(for: .valueChanged)
        }
    }

    private func handleEndedDragging(_ view: UIView) {
        switch view.tag {
        case 1:
            self.leftThumbConstraintLastConstant = self.leftThumbConstraint.constant
            self.leftActiveTrackConstraintLastConstant = self.leftActiveTrackConstraint.constant
        case 2:
            self.rightThumbConstraintLastConstant = self.rightThumbConstraint.constant
            self.rightActiveTrackConstraintLastConstant = self.rightActiveTrackConstraint.constant
        default:
            break
        }
    }

    private func thumbesInOnePlace(byDraggingThumb thumb: UIView) -> Bool {
        let difference = abs(self.leftThumb.center.x - self.rightThumb.center.x)
        let onePlace = difference < 10
        if onePlace {
            self.forceThumbsPositions(byActiveThumb: thumb)
        }
        return onePlace
    }

    private func forceThumbsPositions(byActiveThumb thumb: UIView) {
        defer {
            if [1, 2].contains(thumb.tag) {  }
        }
        switch thumb.tag {
        case 1:
            let newConstant = self.rightThumb.frame.origin.x
            self.leftThumbConstraint.constant = newConstant
            self.leftThumbConstraintLastConstant = newConstant
            self.leftActiveTrackConstraint.constant = newConstant
            self.leftActiveTrackConstraintLastConstant = newConstant
        case 2:
            let centerXDifference = self.rightThumb.center.x - self.leftThumb.center.x
            let newConstant = self.rightThumbConstraint.constant - centerXDifference
            self.rightThumbConstraint.constant = newConstant
            self.rightThumbConstraintLastConstant = newConstant
            self.rightActiveTrackConstraint.constant = newConstant
            self.rightActiveTrackConstraintLastConstant = newConstant
        default:
            break
        }
    }

    // MARK: - Constraints

    private func makeConstraintsForTrack() {
        self.track.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.track.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.track.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.track.heightAnchor.constraint(equalToConstant: 3),
            self.track.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func makeConstraintsForActiveTrack() {
        self.activeTrack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leftActiveTrackConstraint,
            self.rightActiveTrackConstraint,
            self.activeTrack.topAnchor.constraint(equalTo: self.track.topAnchor),
            self.activeTrack.bottomAnchor.constraint(equalTo: self.track.bottomAnchor)
        ])
    }

    private func makeConstraintsForThumbs() {
        [self.leftThumb, self.rightThumb].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 26).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 26).isActive = true
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        self.leftThumbConstraint.isActive = true
        self.rightThumbConstraint.isActive = true
    }

    private lazy var leftThumbConstraint: NSLayoutConstraint = {
        return self.leftThumb.leadingAnchor.constraint(greaterThanOrEqualTo: self.track.leadingAnchor)
    }()

    private lazy var rightThumbConstraint: NSLayoutConstraint = {
        return self.rightThumb.trailingAnchor.constraint(lessThanOrEqualTo: self.track.trailingAnchor)
    }()

    private var leftThumbConstraintLastConstant: CGFloat = .zero
    private var rightThumbConstraintLastConstant: CGFloat = .zero

    private lazy var leftActiveTrackConstraint: NSLayoutConstraint = {
        return self.activeTrack.leftAnchor.constraint(equalTo: self.track.leftAnchor)
    }()

    private lazy var rightActiveTrackConstraint: NSLayoutConstraint = {
        return self.activeTrack.rightAnchor.constraint(equalTo: self.track.rightAnchor)
    }()

    private var leftActiveTrackConstraintLastConstant: CGFloat = .zero
    private var rightActiveTrackConstraintLastConstant: CGFloat = .zero
} {

    // MARK: - UI

    private lazy var track = UIView()
    private lazy var activeTrack = UIView()
    private lazy var leftThumb = UIImageView()
    private lazy var rightThumb = UIImageView()

    // MARK: - Initialization

    public convenience init(minimumValue: Float = .zero, maximumValue: Float = .zero) {
        self.init()
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
    }

    private override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.addSubviews()
        self.setupSubviews()
        self.makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    public var minimumValue: Float = .zero
    public var maximumValue: Float = .zero

    public var values: (minimum: Float, maximum: Float) {
        get { return (self.minimumValueNow, self.maximumValueNow) }
        set {
            var newMin: Float = .zero; var newMax: Float = .zero
            if newValue.0 <= .zero {
                newMin = self.minimumValue
            }
            if newValue.0 <= self.minimumValue {
                newMin = self.minimumValue
            }
            if newValue.0 > newValue.1 {
                newMin = newValue.1
            }
            if newValue.1 <= .zero {
                newMax = self.minimumValue
            }
            if newValue.1 >= self.maximumValue {
                newMax = self.maximumValue
            }
            if newValue.1 < newValue.0 {
                newMax = newValue.0
            }
            self.minimumValueNow = newMin
            self.maximumValueNow = newMax
        }
    }

    // MARK: - Private API

    private var minimumValueNow: Float = .zero
    private var maximumValueNow: Float = .zero

    private func updateValues(_ completion: @escaping () -> Void) {
        self.minimumValueNow = self.newMinimalValue
        self.maximumValueNow = self.newMaximumValue
        let originXDifference = abs(self.rightThumb.frame.origin.x - self.leftThumb.frame.origin.x)
        if originXDifference < 20 {
            self.minimumValueNow = self.maximumValueNow
        }
        completion()
    }

    private var newMinimalValue: Float {
        let leftThumbOriginX = self.leftThumbConstraint.constant
        let halfOfThumbWidth = self.leftThumb.frame.size.width / 2
        let distancePassed = leftThumbOriginX + halfOfThumbWidth
        let totalDistance = self.track.frame.size.width
        let distancePassedFraction = distancePassed / totalDistance
        if leftThumbOriginX < 3 {
            return self.minimumValue
        }
        if totalDistance - (leftThumbOriginX + self.leftThumb.frame.size.width) < 3 {
            return self.maximumValue
        }
        let newValue: Float = {
            let difference = self.maximumValue - self.minimumValue
            let addingValue = Float(distancePassedFraction) * difference
            return self.minimumValue + addingValue
        }()
        return newValue
    }

    private var newMaximumValue: Float {
        let constraintConstant = abs(self.rightThumbConstraint.constant)
        let distancePassed = constraintConstant + self.leftThumb.frame.size.width / 2
        let totalDistance = self.track.frame.size.width
        let distancePassedFraction = distancePassed / totalDistance
        if constraintConstant < 3 {
            return self.maximumValue
        }
        if totalDistance - (self.rightThumb.frame.size.width + constraintConstant) < 3 {
            return self.minimumValue
        }
        let newValue: Float = {
            let difference = self.maximumValue - self.minimumValue
            let addingValue = difference * Float(distancePassedFraction)
            return self.maximumValue - addingValue
        }()
        return newValue
    }

    // MARK: - View Programmatically

    public func addSubviews() {
        self.addSubview(self.track)
        self.track.addSubview(self.activeTrack)
        self.addSubview(self.leftThumb)
        self.addSubview(self.rightThumb)
    }

    public func setupSubviews() {
        self.setupItself()
        self.setupTrack()
        self.setupActiveTrack()
        self.setupThumbs()
    }

    public func makeConstraints() {
        defer {
            [self.leftThumb, self.rightThumb].forEach { self.bringSubviewToFront($0) }
        }
        self.makeConstraintsForTrack()
        self.makeConstraintsForThumbs()
        self.makeConstraintsForActiveTrack()
    }

    // MARK: - Setups

    private func setupItself() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupTrack() {
        self.track.layer.masksToBounds = true
        self.track.layer.cornerRadius = 1.5
        self.track.backgroundColor = A.superLightGrayBackground.color
        self.track.clipsToBounds = true
    }

    private func setupActiveTrack() {
        self.activeTrack.backgroundColor = A.purpleishBlue.color
    }

    private func setupThumbs() {
        [self.leftThumb, self.rightThumb].forEach {
            $0.image = A.sliderThumb.image
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.isUserInteractionEnabled = true
            let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.dragThumb(using:)))
            $0.addGestureRecognizer(gesture)
        }
        self.leftThumb.tag = 1
        self.rightThumb.tag = 2
    }

    @objc private func dragThumb(using gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began:
            if [1, 2].contains(view.tag) { self.bringSubviewToFront(view) }
        case .changed:
            self.handleDragging(view, withTranslation: translation)
        case .ended:
            self.handleEndedDragging(view)
        default:
            break
        }
    }

    private func handleDragging(_ view: UIView, withTranslation translation: CGPoint) {
        switch view.tag {
        case 1:
            self.handleDraggingLeftThumb(view, withTranslation: translation)
        case 2:
            self.handleDraggingRightThumb(view, withTranslation: translation)
        default:
            break
        }
    }

    private func handleDraggingLeftThumb(_ thumb: UIView, withTranslation translation: CGPoint) {
        let newConstant = translation.x + self.leftThumbConstraintLastConstant
        guard newConstant > -0.001 else {
            self.leftThumbConstraint.constant = .zero
            self.leftActiveTrackConstraint.constant = .zero
            FeedbackManager.shared.vibrate()
            self.updateValues {
                self.sendActions(for: .valueChanged)
            }
            return
        }
        if self.thumbesInOnePlace(byDraggingThumb: thumb) && translation.x > .zero { return }
        self.leftThumbConstraint.constant = newConstant
        self.leftActiveTrackConstraint.constant = newConstant
        self.updateValues {
            self.sendActions(for: .valueChanged)
        }
    }

    private func handleDraggingRightThumb(_ thumb: UIView, withTranslation translation: CGPoint) {
        let newConstant = translation.x + self.rightThumbConstraintLastConstant
        guard newConstant < 0.001 else {
            self.rightThumbConstraint.constant = .zero
            self.rightActiveTrackConstraint.constant = .zero
            FeedbackManager.shared.vibrate()
            self.updateValues {
                self.sendActions(for: .valueChanged)
            }
            return
        }
        if self.thumbesInOnePlace(byDraggingThumb: thumb) && translation.x < .zero { return }
        self.rightThumbConstraint.constant = newConstant
        self.rightActiveTrackConstraint.constant = newConstant
        self.updateValues {
            self.sendActions(for: .valueChanged)
        }
    }

    private func handleEndedDragging(_ view: UIView) {
        switch view.tag {
        case 1:
            self.leftThumbConstraintLastConstant = self.leftThumbConstraint.constant
            self.leftActiveTrackConstraintLastConstant = self.leftActiveTrackConstraint.constant
        case 2:
            self.rightThumbConstraintLastConstant = self.rightThumbConstraint.constant
            self.rightActiveTrackConstraintLastConstant = self.rightActiveTrackConstraint.constant
        default:
            break
        }
    }

    private func thumbesInOnePlace(byDraggingThumb thumb: UIView) -> Bool {
        let difference = abs(self.leftThumb.center.x - self.rightThumb.center.x)
        let onePlace = difference < 10
        if onePlace {
            self.forceThumbsPositions(byActiveThumb: thumb)
        }
        return onePlace
    }

    private func forceThumbsPositions(byActiveThumb thumb: UIView) {
        defer {
            if [1, 2].contains(thumb.tag) { FeedbackManager.shared.vibrate() }
        }
        switch thumb.tag {
        case 1:
            let newConstant = self.rightThumb.frame.origin.x
            self.leftThumbConstraint.constant = newConstant
            self.leftThumbConstraintLastConstant = newConstant
            self.leftActiveTrackConstraint.constant = newConstant
            self.leftActiveTrackConstraintLastConstant = newConstant
        case 2:
            let centerXDifference = self.rightThumb.center.x - self.leftThumb.center.x
            let newConstant = self.rightThumbConstraint.constant - centerXDifference
            self.rightThumbConstraint.constant = newConstant
            self.rightThumbConstraintLastConstant = newConstant
            self.rightActiveTrackConstraint.constant = newConstant
            self.rightActiveTrackConstraintLastConstant = newConstant
        default:
            break
        }
    }

    // MARK: - Constraints

    private func makeConstraintsForTrack() {
        self.track.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.track.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.track.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.track.heightAnchor.constraint(equalToConstant: 3),
            self.track.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    private func makeConstraintsForActiveTrack() {
        self.activeTrack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.leftActiveTrackConstraint,
            self.rightActiveTrackConstraint,
            self.activeTrack.topAnchor.constraint(equalTo: self.track.topAnchor),
            self.activeTrack.bottomAnchor.constraint(equalTo: self.track.bottomAnchor)
        ])
    }

    private func makeConstraintsForThumbs() {
        [self.leftThumb, self.rightThumb].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.widthAnchor.constraint(equalToConstant: 26).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 26).isActive = true
            $0.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        }
        self.leftThumbConstraint.isActive = true
        self.rightThumbConstraint.isActive = true
    }

    private lazy var leftThumbConstraint: NSLayoutConstraint = {
        return self.leftThumb.leadingAnchor.constraint(greaterThanOrEqualTo: self.track.leadingAnchor)
    }()

    private lazy var rightThumbConstraint: NSLayoutConstraint = {
        return self.rightThumb.trailingAnchor.constraint(lessThanOrEqualTo: self.track.trailingAnchor)
    }()

    private var leftThumbConstraintLastConstant: CGFloat = .zero
    private var rightThumbConstraintLastConstant: CGFloat = .zero

    private lazy var leftActiveTrackConstraint: NSLayoutConstraint = {
        return self.activeTrack.leftAnchor.constraint(equalTo: self.track.leftAnchor)
    }()

    private lazy var rightActiveTrackConstraint: NSLayoutConstraint = {
        return self.activeTrack.rightAnchor.constraint(equalTo: self.track.rightAnchor)
    }()

    private var leftActiveTrackConstraintLastConstant: CGFloat = .zero
    private var rightActiveTrackConstraintLastConstant: CGFloat = .zero
}
