//
//  ContactService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

class ContactService {
    
    static let shared: ContactService = ContactService()
    private init() {}
    
    private var _contacts: [Contact]?
    var contacts: [Contact] {
        get {
            if _contacts == nil {
                _contacts = loadContacts()
            }
            return _contacts!
        }
    }
    
    private func loadContacts() -> [Contact] {      /* load all contacts */
        var contacts: [Contact] = []
        if DBManager.shared.openDatabase() {
            let query = "select * from contacts"
            do {
                let result = try DBManager.shared.db.executeQuery(query, values: nil)
                while result.next() {
                    let name = result.string(forColumn: String.field_name)!
                    let data = CryptionService.shared.unzipFile(name: name, encryptedType: .contact) ?? Data()
                    if let contact = NSKeyedUnarchiver.unarchiveObject(with: data) as? Contact {
                        contacts.append(contact)
                    }
                }
                result.close()
            } catch {
                print(error.localizedDescription)
            }
//            DBManager.shared.closeDatabse()
        }
        return contacts
    }
    
    /* insert a contact to database and create a encrypted file */
    func saveContact(name: String, phone1: String, phone2: String, birthday: String, email: String, imageData: Data?) -> Bool {
        let contact = Contact(name: name,
                              phone1: phone1,
                              phone2: phone2,
                              birthday: birthday,
                              email: email,
                              imageData: imageData)
        let data = NSKeyedArchiver.archivedData(withRootObject: contact)
        let path = CryptionService.shared.zipFile(data: data, fileName: name, encryptType: .contact)
        if !path.isEmpty {
            if DBManager.shared.openDatabase() {
                let query = "insert into contacts (\(String.field_name), \(String.field_encryptedPath)) values ('\(name)', '\(path)');"
                if !DBManager.shared.db.executeStatements(query) {
                    DBManager.shared.printError(message: "failed save contact")
                }
//                DBManager.shared.closeDatabse()
                DispatchQueue.global().sync {
                    self._contacts = self.loadContacts()
                }
                return true
            }
        } else {
            print("encrypt contact failed")
        }
        return false
    }
    
    /* update a contact by delete old file and create new file */
    func updateContact(oldName: String, newName: String, phone1: String, phone2: String, birthday: String, email: String, imageData: Data?) -> Bool {
        let contact = Contact(name: newName,
                              phone1: phone1,
                              phone2: phone2,
                              birthday: birthday,
                              email: email,
                              imageData: imageData)
        let data = NSKeyedArchiver.archivedData(withRootObject: contact)
        let oldPath = Constant.contactDir.appending("/\(oldName).txt")
        AppService.shared.deleteFile(at: oldPath)
        let path = CryptionService.shared.zipFile(data: data, fileName: newName, encryptType: .contact)
        if !path.isEmpty {
            if DBManager.shared.openDatabase() {
                let query = "update contacts set \(String.field_name) = '\(newName)', \(String.field_encryptedPath) = '\(path)' where \(String.field_name) = '\(oldName)';"
                if !DBManager.shared.db.executeStatements(query) {
                    DBManager.shared.printError(message: "failed update contact")
                }
//                DBManager.shared.closeDatabse()
                DispatchQueue.global().sync {
                    self._contacts = self.loadContacts()
                }
                return true
            }
        } else {
            print("encrypt contact failed")
        }
        return false
    }
    
    func deleteContact(contact: Contact, completion: (Bool)->()) {      /* delete a contact */
        let path = Constant.contactDir.appending("/\(contact.name!).txt")
        let query = "delete from contacts where \(String.field_name) = '\(contact.name!)';"
        if DBManager.shared.openDatabase() {
            if !DBManager.shared.db.executeStatements(query) {
                DBManager.shared.printError(message: "Can't delete contact")
                completion(false)
                return
            }
            AppService.shared.deleteFile(at: path)
            //DBManager.shared.closeDatabse()
        }
        _contacts = loadContacts()
        completion(true)
    }
}
