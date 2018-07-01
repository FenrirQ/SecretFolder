//
//  RateAppController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/27/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import iRate

extension SettingsTableViewController {
    func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            iRate.sharedInstance().promptForRating()
        }
    }
}
