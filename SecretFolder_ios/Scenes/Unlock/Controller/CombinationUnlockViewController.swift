//
//  CombinationUnlockViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CombinationUnlockViewController: BaseViewController {

    @IBOutlet weak var passPickerView: UIPickerView!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var nativeAdView: UIView!
    
    let dataSize = 100000
    var adLoader: GADAdLoader!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...3 {
            passPickerView.selectRow(dataSize / 2, inComponent: i, animated: true)
        }
        if !AppService.isProVersion {
            setUpNativeAd()
        }
        registerObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @IBAction func onUnlock(_ sender: UIButton) {
        var pass = ""
        for i in 0...3 {
            pass = pass + "\(passPickerView.selectedRow(inComponent: i) % 10)"
        }
        if UserDefaults.standard.string(forKey: String.kPassCode) ?? "" == pass {
            UserDefaults.standard.set(true, forKey: String.kIsUnlock)
            dismiss(animated: true, completion: nil)
        } else {
            topLabel.text = "Try again"
        }
    }
    
}

extension CombinationUnlockViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSize
    }
    
}

extension CombinationUnlockViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = (row == pickerView.selectedRow(inComponent: component)) ? AppColor.appOrange : AppColor.warmBlack
        return NSAttributedString(string: String(row % 10),
                                  attributes: [NSAttributedStringKey.foregroundColor : color])
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
    }
}

extension CombinationUnlockViewController: GADNativeAppInstallAdLoaderDelegate {
    
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

extension CombinationUnlockViewController: GADNativeContentAdLoaderDelegate {
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
