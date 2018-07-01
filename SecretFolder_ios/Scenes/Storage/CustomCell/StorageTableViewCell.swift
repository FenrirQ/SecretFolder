//
//  StorageTableViewCell.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class StorageTableViewCell: UITableViewCell {

    @IBOutlet weak var titleFolder: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var delegate: StorageTableViewCellDelegate!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func editButton(_ sender: UIButton) {
        delegate.storageTableViewCell(self, didTapOnEdit: sender)
    }
}

protocol StorageTableViewCellDelegate {
    func storageTableViewCell(_ cell: StorageTableViewCell, didTapOnEdit sender: UIButton)
}
