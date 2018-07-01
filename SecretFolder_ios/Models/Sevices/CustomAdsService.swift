//
//  CustomAdsService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/26/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import GoogleMobileAds

class CustomAdsService: NSObject {
    
    private static var shared: CustomAdsService?
    
    var bannerAdsShowComplete: ((_ bannerHeight: CGFloat) -> Void)?
    var adsManager: AdsManager
    fileprivate static var isBottom: Bool!
    
    private override init() {
        adsManager = AdsManager()
        super.init()
        adsManager.delegate = self
    }
    
    func bannerAdsDidShow() {
        guard bannerAdsShowComplete != nil else {return}
        bannerAdsShowComplete!(bannerAdsHeight())
        CustomAdsService.shared?.adsManager.transitionBannerBottom(isBottom: CustomAdsService.isBottom)
    }
    
    private func bannerAdsHeight() -> CGFloat {
        if AppService.isProVersion {
            return 0
        } else {
            return CustomAdsService.shared?.adsManager.adBannerHeight() ?? 0
        }
    }
    
    static func initAd() {
        CustomAdsService.shared = CustomAdsService()
        GADMobileAds.configure(withApplicationID: Constant.adAppID)
    }
    
    static func showFullAdsComplete(_ complete: @escaping () -> ()) {
        if AppService.isProVersion {
            return
        } else {
            CustomAdsService.shared?.adsManager.showFullAdsWithForceShow(completion: complete)
        }
    }
    
    static func removeAds() {
        
    }
    
    static func restoreAds() {
        
    }
    
    static func showAdBannerAtBottom(atBottom: Bool, withCompletion complete: ((CGFloat)->())?) {
        if !AppService.isProVersion {
            if CustomAdsService.shared!.adsManager.isAdsShowing() {
                if complete != nil {
                    complete!(CustomAdsService.shared!.adsManager.adBannerHeight())
                    CustomAdsService.shared?.adsManager.transitionBannerBottom(isBottom: atBottom)
                }
            } else {
                CustomAdsService.shared?.bannerAdsShowComplete = complete
                CustomAdsService.shared?.adsManager.setShowHideAd(isShow: true)
            }
            isBottom = atBottom
        } else {
            CustomAdsService.shared!.adsManager.setShowHideAd(isShow: false)
        }
    }
    
    static func hideAdBanner() {
//        if AppService.isProVersion {
//            CustomAdsService.shared?.bannerAdsShowComplete = nil
            CustomAdsService.shared?.adsManager.setShowHideAd(isShow: false)
//        }
    }
    
    
}

extension CustomAdsService: AdsManagerDelegate {
    func adDidReceive() {
        bannerAdsDidShow()
    }
}
