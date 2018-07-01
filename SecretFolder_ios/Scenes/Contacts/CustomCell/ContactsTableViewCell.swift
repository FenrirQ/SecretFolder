//
//  ContactsTableViewCell.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class ContactsTableViewCell: UITableViewCell {
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var emptyCircle: UIView!
    @IBOutlet weak var pickImage: UIImageView!
    
    var delegate: ContactsTableViewCellProtocol!
    
    override func prepareForReuse() {
        iconImage.image = #imageLiteral(resourceName: "contactIcon")
        nameLabel.text = ""
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        delegate.contactsTableViewCell(self, didTapOnEdit: sender)
    }
}

protocol ContactsTableViewCellProtocol {
    func contactsTableViewCell(_ cell: UITableViewCell, didTapOnEdit sender: UIButton)
}
