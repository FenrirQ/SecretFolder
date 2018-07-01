//
//  SecurityUnlockViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import GoogleMobileAds

class SecurityUnlockViewController: BaseViewController {

    @IBOutlet weak var passDot1: UIView!
    @IBOutlet weak var passDot2: UIView!
    @IBOutlet weak var passDot3: UIView!
    @IBOutlet weak var passDot4: UIView!
    
    var passArray: [Int] = []
    var dotArray: [UIView] = []
    var adView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dotArray = [passDot1, passDot2, passDot3, passDot4]
        if !AppService.isProVersion {
            setUpBanner()
        }
        registerObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpBanner() {
        adView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adView.adUnitID = Constant.adBannerUnitID
        adView.delegate = self
        adView.rootViewController = self
        let adBannerView = UIView(frame: CGRect(x: 0,
                                                y: UIScreen.main.bounds.size.height - adView.bounds.size.height,
                                                width: UIScreen.main.bounds.width,
                                                height: adView.bounds.size.height))
        adBannerView.bounds.size.height = adView.bounds.size.height
        view.addSubview(adBannerView)
        adBannerView.addSubview(adView)
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requestAd),
                                               name: NotificationKey.showAdUnlock,
                                               object: nil)
    }
    
    @objc private func requestAd() {
        if !AppService.isProVersion {
            adView.load(GADRequest())
        }
    }
    
    @IBAction func onNumberButton(_ sender: UIButton) {
        if passArray.count >= 4 {
            return
        }
        guard let title = sender.titleLabel?.text else {return}
        guard let number = Int(title) else {return}
        passArray.append(number)
        for i in 0...(passArray.count - 1) {
            dotArray[i].backgroundColor = AppColor.appOrange
        }
        if passArray.count == 4 {
            checkSuccess()
        }
    }
    
    @IBAction func onBackspaceButton(_ sender: UIButton) {
        if passArray.count <= 0 {return}
        passArray.remove(at: passArray.count - 1)
        dotArray[passArray.count].backgroundColor = UIColor.colorFromHexa("D8D8D8")
        navigationItem.rightBarButtonItem = nil
    }
    
    private func checkSuccess() {
        let pass = "\(passArray[0])\(passArray[1])\(passArray[2])\(passArray[3])"
        if UserDefaults.standard.string(forKey: String.kPassCode) ?? "" == pass {
            UserDefaults.standard.set(true, forKey: String.kIsUnlock)
            dismiss(animated: true, completion: nil)
        } else {
                UIView.animate(withDuration: 0.5, animations: {
                    for dot in self.dotArray {
                        dot.backgroundColor = UIColor.colorFromHexa("D0021B")
                    }
                }, completion: { (_) in
                    UIView.animate(withDuration: 0.5, animations: {
                        for dot in self.dotArray {
                            dot.backgroundColor = UIColor.colorFromHexa("D8D8D8")
                        }
                        self.passArray = []
                    })
                })
        }
    }
}

extension SecurityUnlockViewController: GADBannerViewDelegate {
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("success")
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error.localizedDescription)
    }
}
