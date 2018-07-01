//
//  MoreAppObject.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/30/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import SwiftyJSON

class MoreAppObject: NSObject {
    var title: String
    var customURL: String
    var descText: String
    var linkURL: String
    var linkAdImage: String
    var notiID: String
    var linkIcon: String
    var urlIcon: String
    var tryNowText: String
    
    init(_ json: JSON) {
        title = json["Title"].stringValue
        customURL = "\(json["AppId"].stringValue)://"
        descText = json["Description"].stringValue
        linkURL = json["URL"].stringValue
        linkAdImage = json["AdRectangle"].stringValue
        notiID = json["NotificationId"].stringValue
        linkIcon = json["AdImage"].stringValue
        tryNowText = json["TryNowText"].stringValue
        let url: NSString = json["AdIconMoreApps"].stringValue as NSString
        urlIcon = "http://deltago.com/notifications/adv/public/upload/images/\(notiID)/\(url.lastPathComponent)"
        super.init()
    }
}
