//
//  StringExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

extension String {
    func isEmail() -> Bool {        /* check correct format email */
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
