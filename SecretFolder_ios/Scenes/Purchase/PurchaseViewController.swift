//
//  PurchaseViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/5/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation

extension SettingsTableViewController {
    func purchase() {
        showHUD()
        SwiftyStoreKit.purchaseProduct("com.catviet.ios.secretfolder.removeads") { (result) in
            self.hideHUD()
            switch result {
            case .success(let purchase):
                print("success \(purchase)")
                AppService.isProVersion = true
            case .error(let error):
                self.toast(error.localizedDescription)
            }
        }
    }
}
