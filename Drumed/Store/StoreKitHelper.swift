//
//  StoreKitHelper.swift
//  Drumed
//
//  Created by Andrew Donnelly on 01/12/2018.
//  Copyright © 2018 Andrew Donnelly. All rights reserved.
//

import UIKit
import StoreKit
import KeychainAccess
import FirebaseAnalytics

public protocol StoreKitHelperDelegate: AnyObject {
    func storeKitHelperPurchaseComplete()
    func storeKitHelperPurchaseFail()
    func storeKitHelperPurchaseRestored()
    func storeKitHelperPurchaseRestoredFail()
}

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

class StoreKitHelper: NSObject {

    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    weak var delegate: StoreKitHelperDelegate?

    fileprivate var productRequest: SKProductsRequest!
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    var products: [SKProduct]!

    // Get items available
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: "ProductIDs", withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func getIAPProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        //productsRequest.cancel()
        productsRequestCompletionHandler = completionHandler

        guard let productIdentifiers = getProductIDs() else { print("Failed to Get Product IDs"); return }
        productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        productRequest.delegate = self

        // Send the request to the App Store.
        productRequest.start()
        SKPaymentQueue.default().add(self)
    }

    func isSubscribed() -> Bool {
        for product in products {
            if isProductPurchased(product.productIdentifier) {
                return true
            }
        }
        return false
    }

    func isProductSubscribed(productIdentifier: String) -> Bool {
        for product in products {
            if isProductPurchased(product.productIdentifier) && productIdentifier == product.productIdentifier {
                return true
            }
        }
        return false
    }

    // Restore Purchases
    public func restorePurchases() {
        SKPaymentQueue.default().add(self)
      SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // Purchase Product
    public func buyProduct(_ product: SKProduct) {
      let payment = SKPayment(product: product)
      SKPaymentQueue.default().add(payment)
    }

    // Purchase Product
    public func buyProduct(_ productID: String) {
        if let product: SKProduct = getProductForProductID(productID: productID) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }

    // Check can purchase
    func canMakePurchase() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    fileprivate func getProductForProductID(productID: String) -> SKProduct? {
        if products != nil {
            let filteredProds =  products.filter( {$0.productIdentifier == productID }).map({ return $0 })
            return filteredProds.first
        }
        return nil
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        let keychain = Keychain(service: "com.armsreach.drumed.subscriptions")
        // if there is value correspond to the productIdentifier key in the keychain
        if ((try? keychain.get(productIdentifier)) != nil) {
            // the product has been purchased previously, add it to the purchasedProductIdentifiers set
            purchasedProductIdentifiers.insert(productIdentifier)
        }
        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    private func addPurchaseToKeychain(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        // replace the keychain service name as you like
        let keychain = Keychain(service: "com.armsreach.drumed.subscriptions")
        // use the in-app product item identifier as key, and set its value to indicate user has purchased it
        do {
            try keychain.set("purchased", key: identifier)
            Analytics.logEvent("purchased", parameters: [
                "identifier": identifier as NSObject
              ])
        }
        catch let error {
            print("setting keychain to purchased failed \(error)")
        }
    }
}

extension StoreKitHelper: SKRequestDelegate {
    func requestDidFinish(_ request: SKRequest) {}
}

extension StoreKitHelper: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()

        for p in products {
            if isProductPurchased(p.productIdentifier) {
                purchasedProductIdentifiers.insert(p.productIdentifier)
            }
        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    func clearRequestAndHandler() {
        productsRequestCompletionHandler = nil
    }
}

extension StoreKitHelper: SKPaymentTransactionObserver {

  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      @unknown default:
        break
        }
    }
  }

  private func complete(transaction: SKPaymentTransaction) {
    addPurchaseToKeychain(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
    if self.delegate != nil {
        self.delegate?.storeKitHelperPurchaseComplete()
    }
  }

  private func restore(transaction: SKPaymentTransaction) {
    // Should we add it to keychain here ?
    addPurchaseToKeychain(identifier: transaction.payment.productIdentifier)
    SKPaymentQueue.default().finishTransaction(transaction)
  }

  private func fail(transaction: SKPaymentTransaction) {
    if let transactionError = transaction.error as NSError?,
      let localizedDescription = transaction.error?.localizedDescription,
        transactionError.code != SKError.paymentCancelled.rawValue {
        print("Transaction Error: \(localizedDescription)")
      }
    SKPaymentQueue.default().finishTransaction(transaction)
    if self.delegate != nil {
        self.delegate?.storeKitHelperPurchaseFail()
    }
  }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if self.delegate != nil {
            self.delegate?.storeKitHelperPurchaseRestored()
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if self.delegate != nil {
            self.delegate?.storeKitHelperPurchaseRestoredFail()
        }
    }
}
