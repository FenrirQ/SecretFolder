//
//  LockTypeTableViewCell.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/21/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class LockTypeTableViewCell: UITableViewCell {
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        let checkedRow = UserDefaults.standard.integer(forKey: String.kLockType)
        let tag = self.tag
        if tag == checkedRow {
            checkImageView.isHidden = false
        } else {
            checkImageView.isHidden = true
        }
    }
}
