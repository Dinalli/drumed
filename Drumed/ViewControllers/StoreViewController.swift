//
//  StoreTableViewController.swift
//  Drumed
//
//  Created by Andrew Donnelly on 03/02/2020.
//  Copyright © 2020 Andrew Donnelly. All rights reserved.
//

import UIKit
import StoreKit
import SafariServices

public protocol StoreViewControllerDelegate: AnyObject {
    func storeViewControllerPurchaseComplete()
    func storeViewControllerPurchaseFail()
    func storeViewControllerPurchaseRestored()
    func storeViewControllerPurchaseRestoredFail()
}

class StoreViewController: UIViewController {

    weak var delegate: StoreViewControllerDelegate?

    let model = StoreKitViewModel()

    let storeKitHelper = StoreKitHelper()
    var products = [SKProduct]()

    override func viewDidLoad() {
        super.viewDidLoad()
        storeKitHelper.delegate = self
        storeKitHelper.getIAPProducts { (success, products) in
            if success {
                self.products = products ?? [SKProduct]()
                self.updateSubscriptionStatus()
            } else {
                self.showUserToastMessage(message: "Could not get products to purchase", duration: 5.0)
            }
        }
    }

    override func viewWillLayoutSubviews() {
        if !model.viewsLayedOut {
            super.viewWillLayoutSubviews()
            model.layoutViews(view: self.view)
            model.monthlyPurchaseButton.addTarget(self, action: #selector(monthlySubscriptionTapped), for: .touchUpInside)
            model.yearlyPurchaseButton.addTarget(self, action: #selector(yearlySubscriptionTapped), for: .touchUpInside)
            model.restorePurchaseButton.addTarget(self, action: #selector(restorePressed), for: .touchUpInside)
            model.termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
            model.privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
            model.manageSubsButton.addTarget(self, action: #selector(manageSubscriptions), for: .touchUpInside)
        }
    }

    fileprivate func updateSubscriptionStatus() {
        for product in self.products {
            switch product.productIdentifier {
            case "com.armsreach.drumed.monthly":
                if storeKitHelper.isProductPurchased(product.productIdentifier) {
                    DispatchQueue.main.async {
                        self.model.monthlyPurchaseButton.setTitle("Subscribed", for: .normal)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.model.monthlyPurchaseButton.setTitle("\(product.regularPrice) / Month ", for: .normal)
                    }
                }
            case "com.armsreach.drumed.yearly":
                if storeKitHelper.isProductPurchased(product.productIdentifier) {
                    DispatchQueue.main.async {
                        self.model.yearlyPurchaseButton.setTitle("Subscribed", for: .normal)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.model.yearlyPurchaseButton.setTitle("\(product.regularPrice) / Year (12 months)", for: .normal)
                    }
                }
            default:
                break
            }
        }
    }

    @objc func restorePressed() {
        showUserToastMessage(message: "Checking for any previous purchases and restoring them.", duration: 8.0)
        storeKitHelper.restorePurchases()
        dismiss(animated: true, completion: nil)
    }

    @objc func monthlySubscriptionTapped() {
        if storeKitHelper.canMakePurchase() {
            storeKitHelper.buyProduct("com.armsreach.drumed.monthly")
        } else {
            showUserToastMessage(message: "Unfortuntaly you are not permited to make purchases on this account.", duration: 5.0)
        }
    }

    @objc func yearlySubscriptionTapped() {
        if storeKitHelper.canMakePurchase() {
            storeKitHelper.buyProduct("com.armsreach.drumed.yearly")
        } else {
            showUserToastMessage(message: "Unfortuntaly you are not permited to make purchases on this account.", duration: 5.0)
        }
    }

    @objc func termsTapped() {
        let urlString = "https://www.drum-ed.com/drumed-terms"
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.present(safariVC, animated: true)
        }
    }

    @objc func privacyTapped() {
        let urlString = "https://www.drum-ed.com/drumed-privacy-policy"
        if let url = URL(string: urlString) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.present(safariVC, animated: true)
        }
    }

    @objc func manageSubscriptions() {
        guard let url = URL(string: "itms://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension StoreViewController: StoreKitHelperDelegate {
    func storeKitHelperPurchaseComplete() {
        updateSubscriptionStatus()
        if delegate != nil { delegate?.storeViewControllerPurchaseComplete(); dismiss(animated: true, completion: nil) }
    }

    func storeKitHelperPurchaseFail() {
        if delegate != nil { delegate?.storeViewControllerPurchaseFail(); dismiss(animated: true, completion: nil) }
    }

    func storeKitHelperPurchaseRestored() {
        updateSubscriptionStatus()
        if delegate != nil { delegate?.storeViewControllerPurchaseRestored(); dismiss(animated: true, completion: nil) }
    }

    func storeKitHelperPurchaseRestoredFail() {
        if delegate != nil { delegate?.storeViewControllerPurchaseRestoredFail(); dismiss(animated: true, completion: nil) }
    }
}

extension StoreViewController: SFSafariViewControllerDelegate {

}
