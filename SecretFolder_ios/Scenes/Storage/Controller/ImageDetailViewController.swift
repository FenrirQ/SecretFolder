//
//  ImageDetailViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import SnapKit
import AVKit

class ImageDetailViewController: BaseViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playIconImage: UIImageView!
    var media: Media!
    var isVideo: Bool!
    var videoPath: String!              //write video to video directory to play
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isVideo = media.duration != 0
        if isVideo {
            imageView.image = media.thumbImage
            showHUD()
            MediaService.shared.getVideoOriginalPath(video: media) {(path) in
                self.videoPath = path
                self.hideHUD()
                NotificationCenter.default.post(name: NotificationKey.sendVideoPath,
                                                object: nil,
                                                userInfo: [String.videoPathInfoKey : self.videoPath])
            }
        } else {
            imageView.image = media.thumbImage
            MediaService.shared.showFullImage(image: media, completion: { (image) in
                if let image = image {
                    self.imageView.image = image
                }
            })
            playIconImage.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NotificationKey.setNaviTitleImage,
                                        object: nil,
                                        userInfo: [String.mediaInfoKey : media])
    }
    
    deinit {
        if isVideo != nil && isVideo && videoPath != nil {
            AppService.shared.deleteFile(at: Constant.videoDir + videoPath)
        }
    }
    
    //play video
    @IBAction func onPlayVideo(_ sender: UITapGestureRecognizer) {
        if isVideo {
            let videoURL = URL(fileURLWithPath: Constant.videoDir + videoPath)
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        } else {
            NotificationCenter.default.post(name: NotificationKey.tapGestureImage, object: nil)
        }
    }
    
}
