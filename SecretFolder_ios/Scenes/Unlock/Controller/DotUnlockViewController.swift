//
//  DotUnlockViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import CCGestureLock
import GoogleMobileAds

class DotUnlockViewController: BaseViewController {

    @IBOutlet weak var dotLockControl: CCGestureLock!
    @IBOutlet weak var nativeAdView: UIView!
    
    var adLoader: GADAdLoader!
    var dotPass = [NSNumber]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGestureLock()
        if !AppService.isProVersion {
            setUpNativeAd()
        }
        registerObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpNativeAd() {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        adLoader = GADAdLoader(adUnitID: Constant.adNativeUnitID,
                                   rootViewController: self,
                                   adTypes: [GADAdLoaderAdType.nativeContent,
                                             GADAdLoaderAdType.nativeAppInstall],
                                   options: [multipleAdsOptions])
        adLoader.delegate = self
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requestAd),
                                               name: NotificationKey.showAdUnlock,
                                               object: nil)
    }
    
    @objc private func requestAd() {
        if !AppService.isProVersion {
            adLoader.load(GADRequest())
        }
    }
    
    private func setupGestureLock() {
        // Set number of sensors
        dotLockControl.lockSize = (3, 3)
        // Sensor grid customisations
        dotLockControl.edgeInsets = UIEdgeInsetsMake(30, 30, 30, 30)
        // Sensor point customisation (normal)
        dotLockControl.setSensorAppearance(type: .inner, radius: 5, width: 10, color: AppColor.lightGray, forState: .normal)
        dotLockControl.setSensorAppearance(type: .outer, color: .blue, forState: .normal)
        // Sensor point customisation (selected)
        dotLockControl.setSensorAppearance(type: .inner, radius: 5, width: 10, color: AppColor.appOrange, forState: .selected)
        dotLockControl.setSensorAppearance(type: .outer, radius: 30, width: 3, color: AppColor.appOrange, forState: .selected)
        // Sensor point customisation (wrong password)
        dotLockControl.setSensorAppearance(
            type: .inner,
            radius: 5,
            width: 10,
            color: .red,
            forState: .error
        )
        dotLockControl.setSensorAppearance(
            type: .outer,
            radius: 30,
            width: 3,
            color: .red,
            forState: .error
        )
        // Line connecting sensor points (normal/selected)
        [CCGestureLock.GestureLockState.normal, CCGestureLock.GestureLockState.selected].forEach { (state) in
            dotLockControl.setLineAppearance(
                width: 5.5,
                color: AppColor.appOrange.withAlphaComponent(0.5),
                forState: state
            )
        }
        // Line connection sensor points (wrong password)
        dotLockControl.setLineAppearance(
            width: 5.5,
            color: UIColor.red.withAlphaComponent(0.5),
            forState: .error
        )
        dotLockControl.addTarget(
            self,
            action: #selector(gestureComplete),
            for: .gestureComplete
        )
    }
    
    @objc func gestureComplete(gestureLock: CCGestureLock) {
        guard let numbers = UserDefaults.standard.value(forKey: String.kDotPass) as? [NSNumber] else {return}
        if numbers == dotLockControl.lockSequence {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                UserDefaults.standard.set(true, forKey: String.kIsUnlock)
                self.dismiss(animated: true, completion: nil)
            })
        } else {
            gestureLock.gestureLockState = .error
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                gestureLock.gestureLockState = .normal
            })
        }
    }

}

extension DotUnlockViewController: GADNativeAppInstallAdLoaderDelegate {
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd) {
        let appInstallAdView = Bundle.main.loadNibNamed("NativeAppInstallAdView", owner: nil,
                                                        options: nil)?.first as! GADNativeAppInstallAdView
        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
        (appInstallAdView.imageView as! UIImageView).image = (nativeAppInstallAd.images?.first as! GADNativeAdImage).image
        (appInstallAdView.callToActionView as! UIButton).setTitle(nativeAppInstallAd.callToAction,
                                                                  for: UIControlState.normal)
        (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        nativeAdView.addSubview(appInstallAdView)
        appInstallAdView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
    
}

extension DotUnlockViewController: GADNativeContentAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
        let contentAdView = Bundle.main.loadNibNamed(
            "NativeContentAdView", owner: nil, options: nil)?.first as! GADNativeContentAdView
        contentAdView.nativeContentAd = nativeContentAd
        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
        (contentAdView.imageView as! UIImageView).image = (nativeContentAd.images?.first as! GADNativeAdImage).image
        (contentAdView.callToActionView as! UIButton).setTitle(nativeContentAd.callToAction,
                                                               for: UIControlState.normal)
        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        nativeAdView.addSubview(contentAdView)
        contentAdView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
}

