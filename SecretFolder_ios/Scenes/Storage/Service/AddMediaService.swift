//
//  AddMediaService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/16/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit
import Photos

class AddMediaService {
    static func getMediaName(isVideo: Bool, sourcePath: String) -> String {
        if !sourcePath.isEmpty {
            let name = (sourcePath as NSString).lastPathComponent
            return name
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, YYYY, HH:mm:ss"
            if isVideo {
                return formatter.string(from: Date()) + ".MOV"
            }
            return formatter.string(from: Date())
        }
    }
    
    static func getMediaCreationDate(asset: PHAsset?) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d,YYYY,HH:mm"
        let date = asset?.creationDate ?? Date()
        return formatter.string(from: date)
    }
    
    static func getMediaSize(data: Data) -> Double {
        let mediaSize = data.count
        let size = Double(round(Double(100*mediaSize / (1024 * 1024))) / 100)
        return size
    }
    
    
    
}
