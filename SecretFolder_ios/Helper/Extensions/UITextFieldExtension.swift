//
//  UITextFieldExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/22/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

extension UITextField {
    func customPlaceholder(_ str: String, size: CGFloat) {
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: size)]
        self.attributedPlaceholder = NSAttributedString(string: str, attributes: attributes)
    }
}
