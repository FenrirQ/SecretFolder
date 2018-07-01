//
//  AdsManager.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/25/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsManager: NSObject {
    
    /* private var isNewVersionInTestOrReviewTime: Bool!       /* trick app store feature */ */
    private var isBannerAdShowing: Bool!
    private var bannerView: UIView!
    private var adBannerView: GADBannerView!
    private var interstitial: GADInterstitial!
    private var isProVersion: Bool!
    weak var delegate: AdsManagerDelegate?
    fileprivate var interstitialComplete: (() -> ())?
    fileprivate var isAdShowing: Bool!
    
    override init() {
        super.init()
        isProVersion = AppService.isProVersion
        initMopubAdController()
    }
    
    func initMopubAdController() {
        adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = Constant.adBannerUnitID
        adBannerView.delegate = self
        adBannerView.rootViewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController
        adBannerView.load(GADRequest())
        interstitial = GADInterstitial(adUnitID: Constant.adInterstitialUnitID)
        interstitial.delegate = self
        let sizeBanner = adBannerView.bounds.size
        let screenSize = UIScreen.main.bounds.size
        let rectBanner = CGRect(x: 0,
                                y: screenSize.height + sizeBanner.height,
                                width: screenSize.width,
                                height: sizeBanner.height)
        bannerView = UIView(frame: rectBanner)
        bannerView.backgroundColor = .white
        bannerView.addSubview(adBannerView)
        bannerView.isHidden = true
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.view.addSubview(bannerView)
        isAdShowing = false
    }
    
    func adBannerHeight() -> CGFloat {
        return adBannerView.bounds.size.height
    }
    
    func showFullAdsWithForceShow(completion: @escaping () -> ()) {
        if isProVersion {
            return
        }
        interstitial = GADInterstitial(adUnitID: Constant.adInterstitialUnitID)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        UserDefaults.standard.set(false, forKey: String.kReadyForShowFullAd)
        interstitialComplete = completion
    }
    
    func isAdsShowing() -> Bool {
        return isAdShowing
    }
    
    
    func setShowHideAd(isShow: Bool) {
        if isProVersion {
            bannerView.isHidden = true
            return
        }
        if isShow {
            if Ultilities.isInternetAvailable() {
                bannerView.isHidden = false
            } else {
                bannerView.isHidden = true
            }
        } else {
            bannerView.isHidden = true
        }
    }
    
    func transitionBannerBottom(isBottom: Bool) {
        var rect = bannerView.frame
        let adBannerSize = adBannerView.bounds.size
        let screenSize = UIScreen.main.bounds.size
        if isBottom {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone && screenSize.height == 812 {
                rect.origin.y = screenSize.height - 32 - adBannerSize.height
            } else {
                rect.origin.y = screenSize.height - adBannerSize.height
            }
        } else {
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone && screenSize.height == 812 {
                rect.origin.y = screenSize.height - 49 - 32 - adBannerSize.height - 0.5
            } else {
                rect.origin.y = screenSize.height - 49 - adBannerSize.height - 0.5
            }
        }
        bannerView.frame = rect
        bannerView.isHidden = false
    }
}

extension AdsManager: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        delegate?.adDidReceive!()
        isAdShowing = true
        print("Ad received sucessfully")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
}

extension AdsManager: GADInterstitialDelegate {
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        guard let root = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController else {return}
        ad.present(fromRootViewController: root)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if interstitialComplete != nil {
            interstitialComplete!()
        }
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
        AdsTimer.shared.startTimer()
    }
}

@objc protocol AdsManagerDelegate {
    @objc optional func adsManagerDidReloadProVersion()
    @objc optional func adDidReceive()
}
