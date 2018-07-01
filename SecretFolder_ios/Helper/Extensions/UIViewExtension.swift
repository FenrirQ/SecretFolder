//
//  UIViewExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import Toast_Swift

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {      /* set corner radius on storyboard */
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {       /* set border color on storyboard */
        get {
            return UIColor(cgColor: self.layer.borderColor ?? UIColor.white.cgColor)
        }
        set {
            self.layer.borderColor = newValue.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {       /* set border width on storyboard */
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
        }
    }
    
    func showHUD() {        /* show HUD to alert */
        self.makeToastActivity(.center)
    }
    
    func hideHUD() {            /* hide HUD for .progrss HUD type */
        self.hideToastActivity()
    }
    
    func toast(_ message: String) {             /* show toast message */
        self.makeToast(message, duration: 1.0, position: .center)
    }
}
