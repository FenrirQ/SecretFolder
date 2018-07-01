//
//  DateExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import Foundation

extension Date {
    var year: Int {             /* get year from date */
        get {
            return Calendar.autoupdatingCurrent.dateComponents([.year], from: self).year ?? 0
        }
    }
    
    func getDateForNote() -> String {           /* create format for date of each note */
        let formatter = DateFormatter()
        formatter.dateFormat = "- MM-dd-YYYY - hh:mm"
        return formatter.string(from: self)
    }
}
