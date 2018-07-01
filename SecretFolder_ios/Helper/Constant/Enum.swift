//
//  Enum.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/14/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

enum WroteFileType {        /* type when write a data to a file */
    case text
    case original
}

enum EncryptFileType {      /* type when encryp a data to a data */
    case image
    case imageThumb
    case video
    case videoThumb
    case note
    case contact
}

enum SegmentType: Int {     /* segment type when user choose show image, video or all in media screen */
    case all
    case image
    case video
}

enum ContactMode {          /* modes when show contact detail screen */
    case detail
    case edit
    case new
}

enum SectionType: Int {     /* section type of settings table view */
    case upgrade
    case lock
    case passCode
    case more
}

enum CellType {             /* cell type of settings table view */
    case upgrade
    case restore
    case dotLock
    case combinationLock
    case securityCode
    case setPass
    case feedback
    case rate
    case share
    
    var indexPath: IndexPath {
        switch self {
        case .upgrade:
            return IndexPath(row: 0, section: 0)
        case .restore:
            return IndexPath(row: 1, section: 0)
        case .dotLock:
            return IndexPath(row: 0, section: 1)
        case .combinationLock:
            return IndexPath(row: 1, section: 1)
        case .securityCode:
            return IndexPath(row: 2, section: 1)
        case .setPass:
            return IndexPath(row: 0, section: 2)
        case .feedback:
            return IndexPath(row: 0, section: 3)
        case .rate:
            return IndexPath(row: 1, section: 3)
        case .share:
            return IndexPath(row: 2, section: 3)
        }
    }
}

enum ContactError {
    case lackInfo
    case invalidEmail
    case noError
}
