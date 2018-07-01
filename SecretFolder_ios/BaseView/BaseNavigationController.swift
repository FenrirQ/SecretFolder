//
//  BaseNavigationController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        self.delegate = self
    }
    
    func setUp() {
        self.navigationBar.isOpaque = true
        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = AppColor.appOrange
        self.navigationBar.barTintColor = .white
        self.view.backgroundColor = .white
        var titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: AppColor.warmBlack,
                                       NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)]
        if #available(iOS 8.2, *) {
            titleDict = [NSAttributedStringKey.foregroundColor: AppColor.warmBlack,
                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)]
        }
        self.navigationBar.titleTextAttributes = titleDict as? [NSAttributedStringKey:Any]
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
}

extension BaseNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let currentVC = self.topViewController {
            let itemBack = UIBarButtonItem(title: "", style: .done, target: currentVC, action: nil)
            currentVC.navigationItem.backBarButtonItem = itemBack
        }
    }
}
