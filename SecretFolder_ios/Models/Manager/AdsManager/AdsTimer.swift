//
//  AdsTimer.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/4/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation

class AdsTimer: NSObject {
    static let shared: AdsTimer = AdsTimer()
    private override init() {
        super.init()
    }
    private var timer = Timer()
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: Constant.secondsForShowFullAd,
                                     target: self,
                                     selector: #selector(completionTimer),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    @objc private func completionTimer() {
        UserDefaults.standard.set(true, forKey: String.kReadyForShowFullAd)
        timer.invalidate()
    }
    
}
