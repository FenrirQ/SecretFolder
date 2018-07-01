//
//  MoreAppService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/1/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MoreAppService: APIServiceObject {
    static let sharedInstance: MoreAppService = {
        let instance = MoreAppService()
        return instance
    }()
    
    func getMoreApp(_ completion: @escaping ([MoreAppObject]) -> ()) {
        let request = APIRequestProvider.shareInstance.getMoreApp()
        self.serviceAgent.startRequest(request) { (json, error) in
            if error == nil {
                let jsons = json["notifications"].arrayValue
                var models = [MoreAppObject]()
                for json in jsons {
                    models.append(MoreAppObject(json))
                }
                completion(models)
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
        addToQueue(request)
    }
}
