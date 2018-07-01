//
//  BaseViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint?
    var isAdAtBottom: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppService.isProVersion {
            hideBanner()
        } else {
            showAdBanner()            
        }
    }
    
    deinit {
        AppService.shared.checkShowFullAds()
    }
    
    class func initWithNib() -> Self {
        let bundle = Bundle.main
        let fileManege = FileManager.default
        let nibName = String(describing: self)
        if let pathXib = Bundle.main.path(forResource: nibName, ofType: "nib") {
            if fileManege.fileExists(atPath: pathXib) {
                return initWithNibTemplate()
            }
        }
        if let pathStoryboard = bundle.path(forResource: nibName, ofType: "storyboardc") {
            if fileManege.fileExists(atPath: pathStoryboard) {
                return initWithDefautlStoryboard()
            }
        }
        return initWithNibTemplate()
    }
    
    private class func initWithDefautlStoryboard() -> Self {
        var className = String(describing: self)
        if Constant.isIpad {
            if let pathXib = Bundle.main.path(forResource: "\(className)_\(Constant.iPad)",
                ofType: "storyboardc") {
                if FileManager.default.fileExists(atPath: pathXib) {
                    className = "\(className)_\(Constant.iPad)"
                }
            }
        }
        let storyboardId = className
        return instantiateFromStoryboardHelper(storyboardName: className, storyboardId: storyboardId)
    }
    
    private class func instantiateFromStoryboardHelper<T>(storyboardName: String, storyboardId: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    func showAdBanner() {
        CustomAdsService.showAdBannerAtBottom(atBottom: isAdAtBottom) { (height) in
            self.viewBottomConstraint?.constant = height
        }
    }
    
    func hideBanner() {
        CustomAdsService.hideAdBanner()
        viewBottomConstraint?.constant = 0
    }
}
