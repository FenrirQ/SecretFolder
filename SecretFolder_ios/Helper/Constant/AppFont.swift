//
//  AppFont.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class AppFont: NSObject {
    
    class func SFProFont(style: FontStyle, size: CGFloat) -> UIFont {
        if let font = UIFont(name: "SF-Pro-Text-" + style.fontStyle(), size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
}

enum FontStyle {
    case regular
    case bold
    case medium
    case semibold
    
    func fontStyle() -> String {
        switch self {
        case .bold:
            return "Bold"
        case .medium:
            return "Medium"
        case .regular:
            return "Regular"
        case .semibold:
            return "Semibold"
        }
    }
}
