//
//  ContactModel.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/9/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

class Contact: NSObject, NSCoding {
    var name: String!
    var phone1: String!
    var phone2: String!
    var birthday: String!
    var email: String!
    var imageData: Data?
    
    convenience required init(coder decoder: NSCoder) {
        self.init()
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.phone1 = decoder.decodeObject(forKey: "phone1") as! String
        self.phone2 = decoder.decodeObject(forKey: "phone2") as! String
        self.birthday = decoder.decodeObject(forKey: "birthday") as! String
        self.email = decoder.decodeObject(forKey: "email") as! String
        self.imageData = decoder.decodeObject(forKey: "imageData") as? Data
    }
    
    convenience init(name: String, phone1: String, phone2: String, birthday: String, email: String, imageData: Data?) {
        self.init()
        self.name = name
        self.phone1 = phone1
        self.phone2 = phone2
        self.birthday = birthday
        self.email = email
        self.imageData = imageData
    }
    
    func encode(with aCoder: NSCoder) {
        if let name = name {aCoder.encode(name, forKey: "name")}
        if let phone1 = phone1 {aCoder.encode(phone1, forKey: "phone1")}
        if let phone2 = phone2 {aCoder.encode(phone2, forKey: "phone2")}
        if let birthday = birthday {aCoder.encode(birthday, forKey: "birthday")}
        if let email = email {aCoder.encode(email, forKey: "email")}
        if let imageData = imageData {aCoder.encode(imageData, forKey: "imageData")}
    }
}
