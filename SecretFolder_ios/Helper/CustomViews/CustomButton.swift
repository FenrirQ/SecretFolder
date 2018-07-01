//
//  CustomButton.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/21/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    override open var isHighlighted: Bool {         /* set highlight background color for button */
        didSet {
            backgroundColor = isHighlighted ? AppColor.appOrange : UIColor.white
            self.setTitleColor(.white, for: .highlighted)
        }
    }
    
    override open var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
}
