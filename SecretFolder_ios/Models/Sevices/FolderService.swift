//
//  FolderService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/9/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class FolderService {
    static let shared: FolderService = FolderService()
    
    private init() {}
    
    private var _folders: [Folder]?
    
    var folders: [Folder] {
        get {
            if _folders == nil {
                _folders = loadFolders()
            }
            return _folders!
        }
    }
    
    private func loadFolders() -> [Folder] {    /* load all folders */
        var folders: [Folder] = []
        if DBManager.shared.openDatabase() {
            let query = "select * from folders"
            do {
                let result = try DBManager.shared.db.executeQuery(query, values: nil)
                while result.next() {
                    let folder = Folder(id: Int(result.int(forColumn: String.field_id)),
                                        name: result.string(forColumn: String.field_name)!,
                                        size: result.double(forColumn: String.field_size),
                                        amount: Int(result.int(forColumn: String.field_amount)),
                                        ordinal: Int(result.int(forColumn: String.field_ordinal)))
                    folders.append(folder)
                }
                result.close()
            } catch {
                print(error.localizedDescription)
            }
//            DBManager.shared.closeDatabse()
        }
        return folders
    }
    
    func updateFolder(id: Int, medias: [Media]) {   /* update folder when user change media in it */
        var size = 0.0
        let amount = medias.count
        for image in medias {
            size += image.size
        }
        if DBManager.shared.openDatabase() {
            let query = "update folders set \(String.field_size) = \(size), \(String.field_amount) = \(amount) where \(String.field_id) = \(id);"
            if !DBManager.shared.db.executeStatements(query) {
                print("failed update folder")
                print(DBManager.shared.db.lastErrorMessage())
                return
            }
            _folders = loadFolders()
//            DBManager.shared.closeDatabse()
        }
    }
    
    /*update folder when user change its name */
    func editFolder(id: Int, name: String, completion: (Bool)->()) {
        if DBManager.shared.openDatabase() {
            let query = "update folders set \(String.field_name) = '\(name)' where \(String.field_id) = \(id);"
            if !DBManager.shared.db.executeStatements(query) {
                print("fail edit folder")
                print(DBManager.shared.db.lastErrorMessage())
                completion(false)
                return
            }
            _folders = loadFolders()
            completion(true)
//            DBManager.shared.closeDatabse()
        }
    }
    
    func createFolder(name: String, completion: (Bool)->()) {          /* create new folder */
        let validNameArr = validName(name: name)
        if DBManager.shared.openDatabase() {
            let query = "insert into folders (\(String.field_name), \(String.field_ordinal)) values ('\(validNameArr[0])', \(validNameArr[1]));"
            if !DBManager.shared.db.executeStatements(query) {
                print("Failed to insert folder")
                print(DBManager.shared.db.lastErrorMessage())
                completion(false)
                return
            }
            _folders = loadFolders()
            completion(true)
//            DBManager.shared.closeDatabse()
        }
    }
    
    private func validName(name: String) -> [Any] {          /* create valid default name */
        var ordinals = [Int]()
        if name.isEmpty {
            for folder in folders {
                ordinals.append(folder.ordinal)
            }
            if let maxOrdinal = ordinals.max() {
                return ["Album \(maxOrdinal + 1)", (maxOrdinal + 1)]
            } else {
                return ["Album 1", 1]       /* empty folders table */
            }
        }
        return [name, 0]
    }
    
    func deleteFolder(id: Int, completion: @escaping (Bool)->()) {       /* delete a folder */
        if DBManager.shared.openDatabase() {
            let queryFolder = "delete from folders where \(String.field_id) = \(id);"
            if !DBManager.shared.db.executeStatements(queryFolder) {
                DBManager.shared.printError(message: "failed to delete folders")
                completion(false)
                return
            }
            MediaService.shared.medias(ofFolder: id, completion: { (medias, success) in
                if success {
                    for image in medias {
                        AppService.shared.deleteFile(at: image.encryptedPath)
                    }
                    let queryImage = "delete from medias where \(String.field_media_of_folder_id) = \(id)"
                    if !DBManager.shared.db.executeStatements(queryImage) {
                        DBManager.shared.printError(message: "failed to delete medias")
                        completion(false)
                        return
                    }
                    completion(true)
                } else {
                    completion(false)
                }
            })
            self._folders = self.loadFolders()
//            DBManager.shared.closeDatabse()
        }
    }
    
    func reloadAllFolders() {           /* reload all forder when any media delete or move */
        let folders = loadFolders()
        for folder in folders {
            var medias: [Media] = []
            if DBManager.shared.openDatabase() {
                let query = "select * from medias where medias.\(String.field_media_of_folder_id) = \(folder.id);"
                do {
                    let result = try DBManager.shared.db.executeQuery(query, values: nil)
                    while result.next() {
                        let dateArr = result.string(forColumn: String.field_creation_date)!.components(separatedBy: ",")
                        let media = Media(id: Int(result.int(forColumn: String.field_id)),
                                          folderID: Int(result.int(forColumn: String.field_media_of_folder_id)),
                                          name: result.string(forColumn: String.field_name)!,
                                          size: result.double(forColumn: String.field_size),
                                          encryptedPath: result.string(forColumn: String.field_encryptedPath)!,
                                          encryptedThumbPath: result.string(forColumn: String.field_encrypted_thumbPath)!,
                                          thumbImage: UIImage(),
                                          creationDayAndMonth: dateArr[0],
                                          creationYear: dateArr[1],
                                          creationTime: dateArr[2],
                                          duration: Int(result.int(forColumn: String.field_duration)))
                        medias.append(media)
                    }
                } catch {
                    print(error.localizedDescription)
                }
                updateFolder(id: folder.id, medias: medias)
//                DBManager.shared.closeDatabse()
            }
        }
        _folders = loadFolders()
    }
}

struct Folder {
    var id: Int
    var name: String
    var size: Double
    var amount: Int
    var ordinal: Int
}
