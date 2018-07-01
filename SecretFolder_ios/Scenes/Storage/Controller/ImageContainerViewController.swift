//
//  ImageContainerViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/11/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class ImageContainerViewController: BaseViewController {

    @IBOutlet weak var toolBarView: UIView!
    @IBOutlet weak var topBarTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var medias: [Media]!            /* all medias */
    var index: Int!                 /* index of media in array medias when user tap select at previous screen */
    var mediaWhenSwipe: Media!      /* media when user swipe to other page */
    var isVideo: Bool!              /* is media video or image? */
    var videoPath: String?          /* path to original video */
    var delegate: ImageDetailViewControllerProtocol!
    override var isAdAtBottom: Bool {
        return true
    }
    var isHideBar: Bool = false {
        didSet {
            if isHideBar {
                topBarTopConstraint.constant = -70
                toolViewBottomConstraint.constant = -100
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            } else {
                topBarTopConstraint.constant = 0
                toolViewBottomConstraint.constant = 0
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func loadView() {
        super.loadView()
        registerNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? ImageDetailPageViewController {
            pageVC.medias = self.medias
            pageVC.index = self.index
        }
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setNavigationBarTitle),
                                               name: NotificationKey.setNaviTitleImage,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receiveVideoPath),
                                               name: NotificationKey.sendVideoPath,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onHideBar),
                                               name: NotificationKey.tapGestureImage,
                                               object: nil)
    }
    
    @objc func setNavigationBarTitle(_ noti: Notification) {
        guard let dict = noti.userInfo else {return}
        guard let media = dict[String.mediaInfoKey] as? Media else {return}
        self.mediaWhenSwipe = media
        isVideo = media.duration != 0
        customNavigationBar(with: media)
        videoPath = nil
    }
    
    private func customNavigationBar(with media: Media) {       /* custom bar when user swipe to other media */
        if #available(iOS 8.2, *) {
            dateLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.semibold)
            timeLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.semibold)
        } else {
            dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
            timeLabel.font = UIFont.boldSystemFont(ofSize: 10)
        }
        if Int(media.creationYear) ?? 0 < Date().year {
            dateLabel.text = media.creationDayAndMonth + ", " + media.creationYear
        } else {
            dateLabel.text = media.creationDayAndMonth
        }
        timeLabel.text = media.creationTime
    }
    
    @objc func receiveVideoPath(_ noti: Notification) {
        guard let dict = noti.userInfo else {return}
        guard let videoPath = dict[String.videoPathInfoKey] as? String else {return}
        self.videoPath = videoPath
    }
    
    @IBAction func onMove(_ sender: UIButton) {
        var actions: [UIAlertAction] = []
        for folder in FolderService.shared.folders {
            let action = UIAlertAction(title: folder.name, style: .default, handler: { (_) in
                self.showHUD()
                MediaService.shared.moveToOtherFolder(media: self.mediaWhenSwipe, to: folder.id)
                MediaService.shared.medias(ofFolder: self.mediaWhenSwipe.folderID) { (medias, success) in
                    if success {
                        self.delegate.updateMedias(medias: medias)
                        self.hideHUD()
                        self.toast(String.moveSuccess)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            actions.append(action)
        }
        showAlertView(title: nil, message: nil, actions: actions, style: .actionSheet)
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        let saveAction = UIAlertAction(title: "Save to device", style: .default) { (_) in
            if self.isVideo {
                guard self.videoPath != nil else {return}
                UISaveVideoAtPathToSavedPhotosAlbum(Constant.videoDir + self.videoPath!,
                                                    self,
                                                    #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                let image = MediaService.shared.getImageOriginal(image: self.mediaWhenSwipe)
                UIImageWriteToSavedPhotosAlbum(image,
                                               self,
                                               #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) { (_) in
            if self.isVideo {
                guard self.videoPath != nil else {return}
                let url = URL(fileURLWithPath: Constant.videoDir + self.videoPath!)
                self.share(items: [url])
            } else {
                let image = MediaService.shared.getImageOriginal(image: self.mediaWhenSwipe)
                self.share(items: [image])
            }
        }
        showAlertView(title: nil, message: nil, actions: [saveAction, shareAction], style: .actionSheet)
    }
    
    /* save video to library */
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            toast(error.localizedDescription)
        } else {
            self.toast(String.saveMediaSuccess)
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            self.showHUD()
            MediaService.shared.deleteMedia(media: self.mediaWhenSwipe)
            MediaService.shared.medias(ofFolder: self.mediaWhenSwipe.folderID) { (medias, success) in
                if success {
                    self.delegate.updateMedias(medias: medias)
                    FolderService.shared.updateFolder(id: self.mediaWhenSwipe.folderID, medias: medias)
                    self.hideHUD()
                    self.toast(String.deleteSuccess)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        showAlertView(title: "Confirm",
                      message: "Are your sure to delete this file?",
                      actions: [okAction],
                      style: .alert)
    }
    
    @objc func onHideBar() {
        isHideBar = !isHideBar
    }
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

protocol ImageDetailViewControllerProtocol {
    func updateMedias(medias: [Media])
}
