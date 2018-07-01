//
//  UIViewControllerExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

extension UIViewController {
    
    class func initWithNibTemplate<T>() -> T {  /* get a controller from a nib or storyboard */
        var nibName = String(describing: self)
        if Constant.isIpad {
            if let pathXib = Bundle.main.path(forResource: "\(nibName)_\(Constant.iPad)", ofType: "nib") {
                if FileManager.default.fileExists(atPath: pathXib) {
                    nibName = "\(nibName)_\(Constant.iPad)"
                }
            }
        }
        let viewcontroller = self.init(nibName: nibName, bundle: Bundle.main)
        return viewcontroller as! T
    }
    
    func basicAlertWithTitle(_ title: String?, message: String?) {   /* alert with only ok action */
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: String.ok, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* alert with many actions */
    func showAlertView(title: String?,
                       message: String?,
                       actions: [UIAlertAction],
                       style: UIAlertControllerStyle) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        let cancelAction = UIAlertAction(title: String.cancel, style: .cancel, handler: nil)
        for action in actions {
            alertController.addAction(action)
        }
        alertController.addAction(cancelAction)
        alertController.view.tintColor = AppColor.appOrange
        present(alertController, animated: true, completion: nil)
    }
    
    /* alert with text field */
    func showAlertViewWithTextField(title: String?,
                                    message: String?,
                                    actions: [UIAlertAction],
                                    placeHolder: String = "") -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: String.cancel, style: .cancel, handler: nil)
        for action in actions {
            alertController.addAction(action)
        }
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = placeHolder
        })
        alertController.addAction(cancelAction)
        alertController.view.tintColor = AppColor.appOrange
        present(alertController, animated: true, completion: nil)
        return alertController
    }
    
    func share(items: [Any], subject: String = "") {          /* share items with activity controller */
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.excludedActivityTypes = [.saveToCameraRoll]
        activityViewController.setValue(subject, forKey: "subject")
        present(activityViewController, animated: true, completion: nil)
    }
    
    func showSettingsVCFromCurrentController() {        /* show settings table view */
        let containerVC = ContainerViewController.initWithNib()
        let settingsNav = BaseNavigationController(rootViewController: containerVC)
        present(settingsNav, animated: true, completion: nil)
    }
    
    func showHUD() {
        self.view.showHUD()
    }
    
    func hideHUD() {
        self.view.hideHUD()
    }
    
    func toast(_ message: String) {
        self.view.toast(message)
    }
}
