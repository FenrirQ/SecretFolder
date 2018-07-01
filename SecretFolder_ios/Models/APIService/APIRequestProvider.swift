//
//  APIRequestProvider.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/1/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import Alamofire
import Device

class APIRequestProvider: NSObject {
    //MARK: SINGLETON
    static var shareInstance: APIRequestProvider = {
        let instance = APIRequestProvider()
        return instance
    }()
    
    var alamoFireManager: SessionManager
    var appID: String {
        return Bundle.main.bundleIdentifier!
    }
    var udid: String = "defaultudid"
    var version: String = "1.0"
    var vconfig: String = "1"
    var target: String {
        switch Device.type() {
        case .iPhone:
            return "1"
        case .iPad:
            return "2"
        default:
            return ""
        }
    }
    var product: String = "1"
    
    override init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 120 // seconds for testing
        alamoFireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func getMoreApp() -> DataRequest {
        var param = [String : String]()
        param["appid"] = appID
        param["udid"] = udid
        param["version"] = version
        param["vconfig"] = vconfig
        param["target"] = target
        param["product"] = product
        let urlString = "http://deltago.com/notifications/get_notifications.php"
        return alamoFireManager.request(urlString,
                                        method: .get,
                                        parameters: param,
                                        encoding: URLEncoding.default,
                                        headers: nil)
    }
}
