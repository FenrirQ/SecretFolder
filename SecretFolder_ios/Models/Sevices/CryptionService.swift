//
//  CryptionService.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/13/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import RNCryptor
import Gzip

class CryptionService {
    static let shared: CryptionService = CryptionService()
    private var pathToDocument: String!
    
    private init() {}
    
    func zipFile(data: Data, fileName: String, encryptType: EncryptFileType) -> String {
        var docPath = ""
        guard let dataZipped = (data as NSData).gzipped() else {return ""}
        print("zip success")
        if data.count >= 5 {
            docPath = encrypt(data: data, fileName: fileName, encryptType: encryptType)
        } else {
            docPath = encrypt(data: dataZipped, fileName: fileName, encryptType: encryptType)            
        }
        return docPath
    }
    
    func unzipFile(name: String, encryptedType: EncryptFileType) -> Data? {
        guard let data = decrypt(fileName: name, encryptedType: encryptedType) else {return nil}
        if data.isGzipped {
            do {
                let unzipData = try data.gunzipped()
                return unzipData
            } catch {
                print("can't unzip data \(error.localizedDescription)")
            }
        }
        return data
    }
    
    private func encrypt(data: Data, fileName: String, encryptType: EncryptFileType) -> String {
        var docPath = ""
        let firstPathData = data.splitData(offset: Constant.bytesToEncrypt, startByte: 0)[0]
        let secondPathData = data.splitData(offset: Constant.bytesToEncrypt, startByte: 0)[1]
        var cipher = RNCryptor.encrypt(data: firstPathData, withPassword: String.kEncryptPassword)
        let lengthCipherData = NSData(bytes: &cipher.count, length: Constant.firstByteToSaveEncryptedLength)
        let totalData = (lengthCipherData as Data) + cipher + secondPathData    /* (length) + encryptedPath + remain path */
        docPath = AppService.shared.writeDataToFile(data: totalData,
                                                    fileName: fileName,
                                                    encryptType: encryptType,
                                                    writeType: .text)
        return docPath
    }
    
    private func decrypt(fileName: String, encryptedType: EncryptFileType) -> Data? {
        guard let data = AppService.shared.readDataFromDoc(encryptType: encryptedType, fileName: fileName)
            else {return nil}
        let lengthEncryptedData = data.splitData(offset: Constant.firstByteToSaveEncryptedLength, startByte: 0)[0]
        var lengthEncrypted = 0
        (lengthEncryptedData as NSData).getBytes(&lengthEncrypted, length: Constant.firstByteToSaveEncryptedLength)
        let firstPathData = data.splitData(offset: lengthEncrypted)[0]
        let secondPathData = data.splitData(offset: lengthEncrypted)[1]
        do {
            let originalFirstData = try RNCryptor.decrypt(data: firstPathData,
                                                          withPassword: String.kEncryptPassword)
            let originData = originalFirstData + secondPathData
            return originData
        } catch {
            print("can't decrypt data \(error.localizedDescription)")
        }
        return nil
    }
    
    
}
