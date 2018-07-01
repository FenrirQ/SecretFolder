//
//  DataExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/13/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

extension Data {
    /* split a data to 2 paths */
    func splitData(offset: Int, startByte: Int = Constant.firstByteToSaveEncryptedLength) -> [Data] {
        let binary = Binary(data: self)
        let correctOffset = binary.bytes.count >= 10 ? offset : 1
        var firstPathBytes: [UInt8] = []
        var secondPathBytes: [UInt8] = []
        for i in startByte ... correctOffset {
            firstPathBytes.append(binary.bytes[i])
        }
        for i in (correctOffset + 1) ... (binary.bytes.count - 1) {
            secondPathBytes.append(binary.bytes[i])
        }
        let firstPathData = Data(bytes: firstPathBytes)
        let secondPathData = Data(bytes: secondPathBytes)
        return [firstPathData, secondPathData]
    }
}
