//
//  NotesTableViewCell.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/16/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var noteIcon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var emptyCircle: UIView!
    @IBOutlet weak var pickImage: UIImageView!
    
    var delegate: NotesTableViewCellProtocol!
    
    override func awakeFromNib() {
        if UIScreen.main.bounds.width == 320 {
            subLabel.font = subLabel.font.withSize(11)
        }
    }
    
    @IBAction func onEdit(_ sender: UIButton) {
        delegate.noteTableViewCell(self, didTapOnEdit: sender)
    }
    
}

protocol NotesTableViewCellProtocol {
    func noteTableViewCell(_ cell: UITableViewCell, didTapOnEdit sender: UIButton)
}
