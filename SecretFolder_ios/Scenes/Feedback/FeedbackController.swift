//
//  FeedbackController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/27/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import MessageUI

extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func feedback() {
        if !MFMailComposeViewController.canSendMail() {
            toast("Mail services are not available on this device")
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients([Constant.mail])
        composeVC.setSubject("Feedback for 'Secret Files' app ver 1.0 - iOS \(UIDevice.current.systemVersion)/\(UIDevice.current.modelName)")
        composeVC.setMessageBody("Hello", isHTML: false)
        present(composeVC, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error != nil {
            toast(error!.localizedDescription)
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
