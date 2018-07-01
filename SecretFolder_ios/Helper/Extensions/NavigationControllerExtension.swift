//
//  NavigationControllerExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/21/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

extension UINavigationController {
    func hideHairLine() {           /* hide bottom line of navigation bar */
        if let shadowImage = findShadowImage(under: self.navigationBar) {
            shadowImage.isHidden = true
        }
    }
    
    func showHairLine() {           /* show bottom line of navigation bar after hide it */
        if let shadowImage = findShadowImage(under: self.navigationBar) {
            shadowImage.isHidden = false
        }
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return view as? UIImageView
        }
        
        for subview in view.subviews {
            if let imageView = findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
}
