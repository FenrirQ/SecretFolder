//
//  Constant.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

struct Constant {
    static let isIpad = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    static let isIphone = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    static let iPad = "iPad"
    static let iPhone = "iPhone"
    
    static let firstByteToSaveEncryptedLength = 1
    static let bytesToEncrypt = 5
    
    static let docDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    static let zipDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
    
    static let imageDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/image")
    static let videoDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/video")
    static let noteDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/note")
    static let contactDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0].appending("/contact")
    
    static let mail = "support@ppclink.com"
    static let appLink = "https://itunes.apple.com/us/app/secret-directory-files-vault/id1317702609?ls=1&mt=8"
    static let appID = 1317702609
    
    static let adBannerUnitID = "ca-app-pub-9099762180397469/1622905180"
    static let adInterstitialUnitID = "ca-app-pub-9099762180397469/5179006815"
    static let adNativeUnitID = "ca-app-pub-9099762180397469/2122613960"
    static let adAppID = "ca-app-pub-9099762180397469~9574257831"
    
    static let secondsForShowFullAd: TimeInterval = 180
}
