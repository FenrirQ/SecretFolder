//
//  AppDelegateExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/26/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

extension AppDelegate {
    func presentUnlockView() {      /* present unlock view when came in background */
        if !UserDefaults.standard.bool(forKey: String.kIsUnlock) {return}
        let type = UserDefaults.standard.integer(forKey: String.kLockType)
        switch type {
        case CellType.securityCode.indexPath.row:
            let securityUnlockVC = SecurityUnlockViewController.initWithNib()
            if let topVC = UIApplication.topViewController() {
                topVC.present(securityUnlockVC, animated: true, completion: nil)
            }
        case CellType.combinationLock.indexPath.row:
            let combinationUnlockVC = CombinationUnlockViewController.initWithNib()
            if let topVC = UIApplication.topViewController() {
                topVC.present(combinationUnlockVC, animated: true, completion: nil)
            }
        case CellType.dotLock.indexPath.row:
            let dotUnlockVC = DotUnlockViewController.initWithNib()
            if let topVC = UIApplication.topViewController() {
                topVC.present(dotUnlockVC, animated: true, completion: nil)
            }
        default:
            break
        }
        UserDefaults.standard.set(false, forKey: String.kIsUnlock)
    }
    
    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.flatMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
}
