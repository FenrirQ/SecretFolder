//
//  IntExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/1/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

extension Int {
    func durationFromSeconds() -> String {          /* get duration from a specific seconds (for video) */
        let minutes = Int(self / 60)
        var minutesStr = "\(minutes)"
        let seconds = self - minutes * 60
        var secondsStr = "\(seconds)"
        if minutes < 10 {
            minutesStr = "0\(minutes)"
        }
        if seconds < 10 {
            secondsStr = "0\(seconds)"
        }
        return minutesStr + ":" + secondsStr
    }
}
