//
//  MoreAppCollectionViewCell.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/30/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit
import Kingfisher

class MoreAppCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    var delegate: MoreAppCollectionViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.boldSystemFont(ofSize: 23)
        descLabel.font = UIFont.systemFont(ofSize: 17)
        if UIDevice.current.modelName == "iPhone 4" || UIDevice.current.modelName == "iPhone 4s" {
            titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
            descLabel.font = UIFont.systemFont(ofSize: 16)
        }
        self.iconImageView.layer.cornerRadius = 12
        self.iconImageView.layer.masksToBounds = true
        self.shadowView.layer.cornerRadius = 12
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowView.layer.shadowRadius = 6
        self.shadowView.layer.shadowColor = UIColor.black.cgColor
        self.shadowView.layer.shadowOpacity = 0.4
    }
    
    func configData(_ object: MoreAppObject) {
        let title = object.title
        let desc = object.descText
        let linkAdImage = object.linkAdImage
        let notiID = object.notiID
        let linkIcon = object.linkIcon
        titleLabel.text = title
        descLabel.text = desc
        let coverUrlStr = "http://deltago.com/notifications/adv/public/upload/images/\(notiID)/\((linkAdImage as NSString).lastPathComponent)"
        let coverUrl = URL(string: coverUrlStr)
        coverImageView.kf.setImage(with: coverUrl)
        let iconUrlStr = "http://deltago.com/notifications/adv/public/upload/images/\(notiID)/\((linkIcon as NSString).lastPathComponent)"
        let iconUrl = URL(string: iconUrlStr)
        iconImageView.kf.setImage(with: iconUrl)
    }
    
    func sizeForItem() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        return CGSize(width: screenSize.width - 44, height: screenSize.height - 80)
    }
    
    @IBAction func onToStoreButton(_ sender: UIButton) {
        delegate.moreAppCollectionView(self, didTapOnCover: sender)
    }
}

protocol MoreAppCollectionViewCellDelegate {
    func moreAppCollectionView(_ cell: UICollectionViewCell, didTapOnCover: UIButton)
}
