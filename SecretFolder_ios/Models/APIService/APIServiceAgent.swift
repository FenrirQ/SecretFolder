//
//  APIServiceAgent.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 2/1/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class APIServiceAgent: NSObject {
    
    func startRequest(_ request: DataRequest, completion: @escaping(JSON, NSError?) -> Void) {
        request
            .validate()
            .responseJSON { (_ response: DataResponse<Any>) in
                print(request.debugDescription)
                switch response.result {
                case .success:
                    let json            = JSON(response.result.value!)
                    print(json)
                    completion(json, nil)
                case .failure(let error as NSError):
                    completion(JSON.null, error)
                default:
                    break
                }
        }
    }
}
