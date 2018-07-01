//
//  AppService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/14/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import Photos

class AppService {
    static let shared: AppService = AppService()
    private init() {}
    
    static var isProVersion: Bool {
        get {
            return UserDefaults.standard.bool(forKey: String.kInAppPurchaseProUpgrade)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: String.kInAppPurchaseProUpgrade)
        }
    }
    
    func deleteFile(at path: String) {              /* delete a file with path to it */
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch {
            print(error.localizedDescription)
            print("delete file failed")
        }
    }
    
    func deleteMediaFromLibrary(result: PHFetchResult<PHAsset>) {       /* delete a media in library */
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(result)
        }, completionHandler: nil)
    }
    
    func deleteMediaFromLibrary(asset: PHAsset) {       /* delete a media in library */
        let arrayToDelete = NSArray(object: asset)
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(arrayToDelete)
        }, completionHandler: nil)
    }
    
    /* write file with encryptedType (image, video,...) writeType (text or original(video)) */
    func writeDataToFile(data: Data, fileName: String, encryptType: EncryptFileType, writeType: WroteFileType) -> String {
        let writeDirectory = getCorrectDirectory(fileName: fileName, encryptType: encryptType, writeType: writeType)
        let fileURL = URL(fileURLWithPath: writeDirectory)
        do {
            try data.write(to: fileURL)
            print("write success")
        } catch {
            print(error.localizedDescription)
        }
        return "/" + fileURL.lastPathComponent
    }
    
    /* read data from doc with encryptedType (image, video, note,...) */
    func readDataFromDoc(encryptType: EncryptFileType, fileName: String) -> Data? {
        let documentDirectory = getCorrectDirectory(fileName: fileName,
                                                    encryptType: encryptType,
                                                    writeType: .text)
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: documentDirectory))
            return data
        } catch {
            print("can't read data from path")
        }
        return nil
    }
    
    func moveFile(from sourcePath: String, to destPath: String) {   /* move file */
        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(atPath: sourcePath, toPath: destPath)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createDirectories() {  /* create Directories when open app first time to save meida, note,... */
        do {
            try FileManager.default.createDirectory(atPath: Constant.imageDir,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            try FileManager.default.createDirectory(atPath: Constant.videoDir,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            try FileManager.default.createDirectory(atPath: Constant.noteDir,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
            try FileManager.default.createDirectory(atPath: Constant.contactDir,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
        } catch {
            print(error.localizedDescription);
        }
    }
    
    /* get directory of specific type (image, video,...) */
    private func getCorrectDirectory(fileName: String, encryptType: EncryptFileType, writeType: WroteFileType) -> String {
        switch encryptType {
        case .image:
            if writeType == .text {
                return Constant.imageDir.appending("/\(fileName).txt")
            } else {
                return Constant.imageDir.appending("/\(fileName)")
            }
        case .video:
            if writeType == .text {
                return Constant.videoDir.appending("/\(fileName).txt")
            } else {
                return Constant.videoDir.appending("/\(fileName)")
            }
        case .note:
            if writeType == .text {
                return Constant.noteDir.appending("/\(fileName).txt")
            } else {
                return Constant.noteDir.appending("/\(fileName)")
            }
        case .imageThumb:
            return Constant.imageDir.appending("/\(fileName)_thumb.txt")
        case .videoThumb:
            return Constant.videoDir.appending("/\(fileName)_thumb.txt")
        case .contact:
            return Constant.contactDir.appending("/\(fileName).txt")
        }
    }
    
    func checkShowFullAds() {
        if UserDefaults.standard.bool(forKey: String.kReadyForShowFullAd) {
            CustomAdsService.showFullAdsComplete {
                AdsTimer.shared.startTimer()
            }
        }
    }
}
