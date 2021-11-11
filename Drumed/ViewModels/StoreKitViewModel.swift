//
//  StoreKitViewModel.swift
//  Drumed
//
//  Created by Andrew Donnelly on 20/11/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit

class StoreKitViewModel: NSObject {

    var viewsLayedOut: Bool = false
    fileprivate var parentView: UIView!
    private var parentStackView: UIStackView!
    private let titleLabel = UILabel()

    var monthlyPurchaseButton: UIButton!
    var yearlyPurchaseButton: UIButton!
    var restorePurchaseButton: UIButton!

    var termsButton: UIButton!
    var privacyButton: UIButton!
    var manageSubsButton: UIButton!

    func layoutViews(view: UIView) {
        self.parentView = view
        createBackgroundView()
        createParentStackView()
        createPageTitle()
        createSubsText()
        createSubsMonthlyButton()
        createSubsYearlyButton()
        createRestorePurchasesButton()
        createTermsAndPrivacyLinks()
        parentStackView.setCustomSpacing(20.0, after: restorePurchaseButton)
        viewsLayedOut = true
    }

    fileprivate func createBackgroundView() {
        parentView.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(blurredEffectView)
        blurredEffectView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        blurredEffectView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        blurredEffectView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        blurredEffectView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }

    private func createParentStackView() {
        parentStackView = UIStackView(frame: CGRect(x: 0, y: 67, width: self.parentView.frame.width, height: self.parentView.frame.height-250))
        parentStackView.axis = .vertical
        parentStackView.distribution = .fill
        parentStackView.spacing = 5.0
        parentStackView.accessibilityIdentifier = "ParentStackView"
        parentView.addSubview(parentStackView)
        parentStackView.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 10.0).isActive = true
        parentStackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -10.0).isActive = true
        parentStackView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        parentStackView.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    fileprivate func createPageTitle() {
        titleLabel.textAlignment = .center
        titleLabel.text = "Subscriptions"
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.addArrangedSubview(titleLabel)
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.font = UIFont.systemFont(ofSize: 33.0, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        titleLabel.topAnchor.constraint(equalTo: parentStackView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor).isActive = true
    }

    fileprivate func createSubsText() {
        let subsDescLabel = UILabel()
        subsDescLabel.textAlignment = .center
        subsDescLabel.translatesAutoresizingMaskIntoConstraints = false
        subsDescLabel.numberOfLines = 0
        subsDescLabel.textColor = .white
        subsDescLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        subsDescLabel.accessibilityIdentifier = "SubsLabel"
        subsDescLabel.sizeToFit()
        subsDescLabel.text = "Subscribe to get access to the locked loops. You will also have access to any new loops added to the App while subscribed."
        subsDescLabel.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.addArrangedSubview(subsDescLabel)
        subsDescLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0).isActive = true
        subsDescLabel.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor).isActive = true
        subsDescLabel.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor).isActive = true
    }

    fileprivate func createSubsMonthlyButton() {
        let divider = createFieldDivider()
        parentStackView.addArrangedSubview(divider)
        let monthlyLabel = UILabel()
        monthlyLabel.textAlignment = .center
        monthlyLabel.translatesAutoresizingMaskIntoConstraints = false
        monthlyLabel.numberOfLines = 0
        monthlyLabel.textColor = .white
        monthlyLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        monthlyLabel.accessibilityIdentifier = "SubsLabel"
        monthlyLabel.sizeToFit()
        monthlyLabel.text = "Subscribe with first month free."
        monthlyLabel.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.addArrangedSubview(monthlyLabel)
        monthlyLabel.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor).isActive = true
        monthlyLabel.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor).isActive = true
        monthlyPurchaseButton = UIButton.init(type: .custom)
        monthlyPurchaseButton.setTitle(NSLocalizedString("Monthly Subscription", comment: ""), for: .normal)
        monthlyPurchaseButton.accessibilityLabel = NSLocalizedString("Logout", comment: "")
        monthlyPurchaseButton.accessibilityHint = NSLocalizedString("Logout from the App", comment: "")
        monthlyPurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        monthlyPurchaseButton.setTitleColor(.white, for: .normal)
        monthlyPurchaseButton.setTitleShadowColor(.black, for: .normal)
        monthlyPurchaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        monthlyPurchaseButton.backgroundColor = .clear
        monthlyPurchaseButton.layer.borderWidth = 2.0
        monthlyPurchaseButton.layer.borderColor = UIColor.white.cgColor
        monthlyPurchaseButton.layer.cornerRadius = 8.0
        parentStackView.addArrangedSubview(monthlyPurchaseButton)
        monthlyPurchaseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        parentStackView.setCustomSpacing(30.0, after: divider)
        parentStackView.setCustomSpacing(30.0, after: monthlyPurchaseButton)
        //monthlyPurchaseButton.bottomAnchor.constraint(equalTo: stackView.bottomAnchor).isActive = true
    }

    fileprivate func createSubsYearlyButton() {
        let divider = createFieldDivider()
        parentStackView.addArrangedSubview(divider)
        let yearlyLabel = UILabel()
        yearlyLabel.textAlignment = .center
        yearlyLabel.translatesAutoresizingMaskIntoConstraints = false
        yearlyLabel.numberOfLines = 0
        yearlyLabel.textColor = .white
        yearlyLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        yearlyLabel.accessibilityIdentifier = "SubsLabel"
        yearlyLabel.sizeToFit()
        yearlyLabel.text = "Subscribe with first 3 months free."
        yearlyLabel.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.addArrangedSubview(yearlyLabel)
        yearlyLabel.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor).isActive = true
        yearlyLabel.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor).isActive = true
        yearlyPurchaseButton = UIButton.init(type: .custom)
        yearlyPurchaseButton.setTitle(NSLocalizedString("Yearly Subscription", comment: ""), for: .normal)
        yearlyPurchaseButton.accessibilityLabel = NSLocalizedString("Logout", comment: "")
        yearlyPurchaseButton.accessibilityHint = NSLocalizedString("Logout from the App", comment: "")
        yearlyPurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        yearlyPurchaseButton.setTitleColor(.white, for: .normal)
        yearlyPurchaseButton.setTitleShadowColor(.black, for: .normal)
        yearlyPurchaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        yearlyPurchaseButton.backgroundColor = .clear
        yearlyPurchaseButton.layer.borderWidth = 2.0
        yearlyPurchaseButton.layer.borderColor = UIColor.white.cgColor
        yearlyPurchaseButton.layer.cornerRadius = 8.0
        parentStackView.addArrangedSubview(yearlyPurchaseButton)
        yearlyPurchaseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        parentStackView.setCustomSpacing(30.0, after: divider)
        parentStackView.setCustomSpacing(30.0, after: yearlyPurchaseButton)
    }

    fileprivate func createRestorePurchasesButton() {
        let divider = createFieldDivider()
        parentStackView.addArrangedSubview(divider)
        let restoreLabel = UILabel()
        restoreLabel.textAlignment = .center
        restoreLabel.translatesAutoresizingMaskIntoConstraints = false
        restoreLabel.numberOfLines = 0
        restoreLabel.textColor = .white
        restoreLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        restoreLabel.accessibilityIdentifier = "SubsLabel"
        restoreLabel.sizeToFit()
        restoreLabel.text = "If you have previously subscribed and need to restore your purchases."
        restoreLabel.translatesAutoresizingMaskIntoConstraints = false
        parentStackView.addArrangedSubview(restoreLabel)
        restoreLabel.leadingAnchor.constraint(equalTo: parentStackView.leadingAnchor).isActive = true
        restoreLabel.trailingAnchor.constraint(equalTo: parentStackView.trailingAnchor).isActive = true
        restorePurchaseButton = UIButton.init(type: .custom)
        restorePurchaseButton.setTitle(NSLocalizedString("Restore Purchases", comment: ""), for: .normal)
        restorePurchaseButton.accessibilityLabel = NSLocalizedString("Logout", comment: "")
        restorePurchaseButton.accessibilityHint = NSLocalizedString("Logout from the App", comment: "")
        restorePurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        restorePurchaseButton.setTitleColor(.white, for: .normal)
        restorePurchaseButton.setTitleShadowColor(.black, for: .normal)
        restorePurchaseButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        restorePurchaseButton.backgroundColor = .clear
        restorePurchaseButton.layer.borderWidth = 2.0
        restorePurchaseButton.layer.borderColor = UIColor.white.cgColor
        restorePurchaseButton.layer.cornerRadius = 8.0
        parentStackView.addArrangedSubview(restorePurchaseButton)
        restorePurchaseButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        parentStackView.setCustomSpacing(30.0, after: divider)
        parentStackView.setCustomSpacing(60.0, after: restorePurchaseButton)
    }

    fileprivate func createTermsAndPrivacyLinks() {
        let termsStack = UIStackView()
        termsStack.axis = .horizontal
        termsStack.distribution = .fillEqually
        termsButton = UIButton(type: .custom)
        termsButton.setTitle("Terms & Conditions", for: .normal)
        termsButton.titleLabel!.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        manageSubsButton = UIButton(type: .custom)
        manageSubsButton.setTitle("manage subscriptions", for: .normal)
        manageSubsButton.titleLabel!.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        privacyButton = UIButton(type: .custom)
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.titleLabel!.font = UIFont.systemFont(ofSize: 10.0, weight: .regular)
        termsStack.addArrangedSubview(termsButton)
        termsStack.addArrangedSubview(manageSubsButton)
        termsStack.addArrangedSubview(privacyButton)
        parentStackView.addArrangedSubview(termsStack)
    }

    fileprivate func createFieldDivider() -> UIView {
        let divderView = UIView()
        divderView.backgroundColor = .white
        divderView.translatesAutoresizingMaskIntoConstraints = false
        divderView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        divderView.accessibilityIdentifier = "DividerView"
        divderView.layer.shadowOffset = CGSize(width: 0, height: 1)
        divderView.layer.shadowRadius = 1
        divderView.layer.shadowOpacity = 1.0
        divderView.layer.shadowColor = UIColor.gray.cgColor
        return divderView
    }


}
