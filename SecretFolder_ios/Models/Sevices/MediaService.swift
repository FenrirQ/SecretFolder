//
//  ImageService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/10/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import AVFoundation

class MediaService {
    static let shared: MediaService = MediaService()
    private init() {}
    
    /* get all medias from database and encrypted files */
    func medias(ofFolder id: Int, completion: @escaping ([Media], Bool) -> ()) {
        var isSuccess = true
        var medias: [Media] = []
        if DBManager.shared.openDatabase() {
            let query = "select * from medias where medias.\(String.field_media_of_folder_id) = \(id);"
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
                if medias.isEmpty {
                    DispatchQueue.main.async {
                        completion([], true)
                    }
                    return
                }
            } catch {
                print(error.localizedDescription)
                isSuccess = false
                return
            }
            //                DBManager.shared.closeDatabse()
        }
        DispatchQueue.global().async {
            for i in 0 ... (medias.count - 1) {
                var thumb = UIImage()
                if medias[i].duration == 0 {
                    if let thumbData = CryptionService.shared.unzipFile(name: medias[i].name,
                                                                        encryptedType: .imageThumb) {
                        thumb = UIImage(data: thumbData)!
                    }
                } else if medias[i].duration != 0 {
                    if let thumbData = CryptionService.shared.unzipFile(name: medias[i].name,
                                                                        encryptedType: .videoThumb) {
                        thumb = UIImage(data: thumbData)!
                    }
                } else {
                    isSuccess = false
                    break
                }
                medias[i].thumbImage = thumb
            }
            DispatchQueue.main.async {
                if isSuccess {
                    completion(medias.reversed(), isSuccess)
                } else {
                    completion([], isSuccess)
                }
            }
        }
    }
    
    func addMedia(folderID: Int, data: Data, path: String, name: String, size: Double, date: String, duration: Int, completion: @escaping (Bool) -> ()) {
        var isSuccess = true
        var encryptedPath = ""
        var encryptedThumbPath = ""
        DispatchQueue.global().sync {
            if DBManager.shared.openDatabase() {
                if duration == 0 {
                    let thumbImage = UIImage(data: data)?.thumbImage(with: 300)
                    let thumbImageData = UIImageJPEGRepresentation(thumbImage!, 1)
                    encryptedPath = CryptionService.shared.zipFile(data: data,
                                                                       fileName: name,
                                                                       encryptType: .image)
                    encryptedThumbPath = CryptionService.shared.zipFile(data: thumbImageData!,
                                                                            fileName: name,
                                                                            encryptType: .imageThumb)
                } else {
                    guard let thumb = thumbnailForVideoAt(path: path)?.thumbImage(with: 300) else {return}
                    let thumbData = UIImageJPEGRepresentation(thumb, 1)
                    encryptedPath = CryptionService.shared.zipFile(data: data,
                                                                   fileName: name,
                                                                   encryptType: .video)
                    encryptedThumbPath = CryptionService.shared.zipFile(data: thumbData!,
                                                                        fileName: name,
                                                                        encryptType: .videoThumb)
                }
                if encryptedPath.isEmpty || encryptedThumbPath.isEmpty {
                    isSuccess = false
                } else {
                    let query = "insert into medias (\(String.field_media_of_folder_id), \(String.field_name), \(String.field_size), \(String.field_encryptedPath), \(String.field_encrypted_thumbPath), \(String.field_creation_date), \(String.field_duration)) values (\(folderID), '\(name)', \(size), '\(encryptedPath)', '\(encryptedThumbPath)', '\(date)', \(duration))"
                    if !DBManager.shared.db.executeStatements(query) {
                        isSuccess = false
                        print("fail add media")
                        print(DBManager.shared.db.lastError(), DBManager.shared.db.lastErrorMessage())
                    }
                }
                FolderService.shared.reloadAllFolders()
                //                DBManager.shared.closeDatabse()
                DispatchQueue.main.async {
                    completion(isSuccess)
                }
            }
        }
    }
    
    func deleteMedia(media: Media) {
        var dirPath = ""
        if media.duration == 0 {
            dirPath = Constant.imageDir
        } else {
            dirPath = Constant.videoDir
        }
        if DBManager.shared.openDatabase() {
            let query = "delete from medias where \(String.field_id) = \(media.id);"
            if !DBManager.shared.db.executeStatements(query) {
                DBManager.shared.printError(message: "fail delete media")
                return
            }
            FolderService.shared.reloadAllFolders()
//            DBManager.shared.closeDatabse()
        }
        DispatchQueue.global().async {
            AppService.shared.deleteFile(at: dirPath + media.encryptedPath)
            AppService.shared.deleteFile(at: dirPath + media.encryptedThumbPath)
        }
    }
    
    func moveToOtherFolder(media: Media, to folderID: Int) {
        if DBManager.shared.openDatabase() {
            let query = "update medias set \(String.field_media_of_folder_id) = '\(folderID)' where \(String.field_id) = \(media.id);"
            if !DBManager.shared.db.executeStatements(query) {
                DBManager.shared.printError(message: "faild to move media")
                return
            }
            FolderService.shared.reloadAllFolders()
            //DBManager.shared.closeDatabse()
        }
    }
    
    func getImageOriginal(image: Media) -> UIImage {     /* get original image to share */
        guard let data = CryptionService.shared.unzipFile(name: image.name, encryptedType: .image)
            else {return UIImage()}
        guard let image = UIImage(data: data) else {return UIImage()}
        return image
    }
    
    /* get original image to show full screen */
    func showFullImage(image: Media, completion: @escaping (UIImage?)->()) {
        DispatchQueue.global().async {
            guard let data = CryptionService.shared.unzipFile(name: image.name, encryptedType: .image)
                else {DispatchQueue.main.async {completion(nil)} ; return}
            guard let image = UIImage(data: data) else {DispatchQueue.main.async {completion(nil)} ; return}
            DispatchQueue.main.async {completion(image)}
        }
    }
    
    /* decrypt video and return path */
    func getVideoOriginalPath(video: Media, completion: @escaping (String)->()) {
        DispatchQueue.global().async {
            if let data = CryptionService.shared.unzipFile(name: video.name, encryptedType: .video) {
                let path = AppService.shared.writeDataToFile(data: data,
                                                             fileName: video.name,
                                                             encryptType: .video,
                                                             writeType: .original)
                DispatchQueue.main.async {
                    completion(path)
                }
            }
        }
    }
    
    private func thumbnailForVideoAt(path: String) -> UIImage? {  /* get thumb for video */
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef).rotatedByDegrees(deg: 90)
        } catch {
            print("error")
            return nil
        }
    }
}

struct Media {
    var id: Int
    var folderID: Int
    var name: String
    var size: Double
    var encryptedPath: String
    var encryptedThumbPath: String
    var thumbImage: UIImage
    var creationDayAndMonth: String
    var creationYear: String
    var creationTime: String
    var duration: Int
}
