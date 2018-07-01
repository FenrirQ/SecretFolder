//
//  RestoreViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/5/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation


extension SettingsTableViewController {
    func restorePurchase() {
        showHUD()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            self.hideHUD()
            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.toast("Unknown error. Please contact support")
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.toast("All purchases have been restored")
                AppService.isProVersion = true
            } else {
                print("Nothing to Restore")
                self.toast("No previous purchases were found")
            }
        }
    }
}
