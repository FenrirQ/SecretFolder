//
//  FolderDetailViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import DKImagePickerController

class FolderDetailViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var segmentBar: UIView!
    
    let picker = UIImagePickerController()
    var folder: Folder!
    var itemInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var pathsVideoToShare: [String] = []
    var medias: [Media] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var images: [Media] {
        get {
            var arr: [Media] = []
            for media in allMedias {
                if media.duration == 0 {arr.append(media)}
            }
            return arr
        }
    }
    
    var allMedias: [Media]!
    
    var videos: [Media] {
        get {
            var arr: [Media] = []
            for media in allMedias {
                if media.duration != 0 {arr.append(media)}
            }
            return arr
        }
    }
    
    var isEdit: Bool!
    var indexPickArr: [Int] = []
    override var isAdAtBottom: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = folder.name
        isEdit = false
        toolView.isHidden = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onEdit))
        self.showHUD()
        segmentControl.tintColor = AppColor.appOrange
        MediaService.shared.medias(ofFolder: folder.id) {[weak self] (medias, isSuccess) in
            if !isSuccess {
                self?.hideHUD()
                self?.toast(String.errorMess)
            } else {
                self?.medias = medias
                self?.allMedias = medias
                self?.hideHUD()
            }
        }
    }
    
    deinit {
        for path in pathsVideoToShare {
            AppService.shared.deleteFile(at: Constant.videoDir + path)
        }
    }
    
    @objc func onEdit() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onCancel))
        isEdit = true
        toolView.isHidden = false
        segmentControl.isEnabled = false
    }
    
    @objc func onCancel() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onEdit))
        indexPickArr = []
        isEdit = false
        toolView.isHidden = true
        segmentControl.isEnabled = true
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hideHairLine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.showHairLine()
    }
    
    fileprivate func getCorrectArr() -> [Media] {
        switch segmentControl.selectedSegmentIndex {
        case SegmentType.all.rawValue:
            return allMedias
        case SegmentType.image.rawValue:
            return images
        case SegmentType.video.rawValue:
            return videos
        default:
            return []
        }
    }
    
    func onAddImage() {
        picker.delegate = self
        let galleryAction = UIAlertAction(title: String.chooseFromLibrary, style: .default) { [weak self](_) in
            self?.chooseFromLibrary()
        }
        let cameraAction = UIAlertAction(title: String.takeFromCamera, style: .default) {[weak self] (_) in
            self?.shootPhoto()
        }
        let actions = [galleryAction, cameraAction]
        self.showAlertView(title: nil, message: nil, actions: actions, style: .actionSheet)
    }
    
    @IBAction func onMove(_ sender: UIButton) {
        if indexPickArr.isEmpty {
            toast(String.chooseMinItem)
            return
        }
        var actions: [UIAlertAction] = []
        let medias = getCorrectArr()
        for folder in FolderService.shared.folders {
            let action = UIAlertAction(title: folder.name, style: .default, handler: { (_) in
                self.toast(String.chooseMinItem)
                for index in self.indexPickArr {
                    MediaService.shared.moveToOtherFolder(media: medias[index - 1], to: folder.id)
                    MediaService.shared.medias(ofFolder: medias[index - 1].folderID) { (medias, success) in
                        if success {
                            self.onCancel()
                            self.allMedias = medias
                            self.medias = self.getCorrectArr()
                            self.hideHUD()
                        }
                    }
                }
            })
            actions.append(action)
        }
        showAlertView(title: nil, message: nil, actions: actions, style: .actionSheet)
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        if indexPickArr.isEmpty {
            toast(String.chooseMinItem)
            return
        }
        let saveAction = UIAlertAction(title: "Save to device", style: .default) {[weak self] (_) in
            self?.onSave()
        }
        let shareAction = UIAlertAction(title: "Share", style: .default) {[weak self] (_) in
            self?.onShare()
        }
        showAlertView(title: nil, message: nil, actions: [saveAction, shareAction], style: .actionSheet)
    }
    
    private func onSave() {
        self.showHUD()
        let medias = getCorrectArr()
        for index in indexPickArr {
            if medias[index - 1].duration != 0 {
                MediaService.shared.getVideoOriginalPath(video: medias[index - 1], completion: { (path) in
                    UISaveVideoAtPathToSavedPhotosAlbum(Constant.videoDir + path, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    self.videoPath = path
                })
            } else {
                let image = MediaService.shared.getImageOriginal(image: medias[index - 1])
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        }
        self.onCancel()
        self.medias = self.getCorrectArr()
        self.hideHUD()
        self.toast(String.saveMediaSuccess)
    }
    
    private func onShare() {
        let medias = getCorrectArr()
        var items: [Any] = []
        showHUD()
        for index in indexPickArr {
            if medias[index - 1].duration != 0 {
                MediaService.shared.getVideoOriginalPath(video: medias[index - 1], completion: { (path) in
                    let url = URL(fileURLWithPath: Constant.videoDir + path)
                    items.append(url)
                    self.pathsVideoToShare.append(path)
                })
            } else {
                let image = MediaService.shared.getImageOriginal(image: medias[index - 1])
                items.append(image)
            }
        }
        hideHUD()
        share(items: items)
    }
    
    var videoPath = ""
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            AppService.shared.deleteFile(at: Constant.videoDir + videoPath)
        }
    }
    
    @IBAction func onDelete(_ sender: UIButton) {
        if indexPickArr.isEmpty {
            toast(String.chooseMinItem)
            return
        }
        var message = ""
        if indexPickArr.count == 1 {message = "Are you sure to delete this file?"}
        else {message = "Are you sure to delete these files?"}
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            self.showHUD()
            let medias = self.getCorrectArr()
            for index in self.indexPickArr {
                MediaService.shared.deleteMedia(media: medias[index - 1])
            }
            MediaService.shared.medias(ofFolder: self.folder.id) { (medias, _) in
                self.onCancel()
                self.allMedias = medias
                self.medias = self.getCorrectArr()
                self.hideHUD()
                self.toast(String.deleteSuccess)
            }
        }
        showAlertView(title: "Confirm", message: message, actions: [okAction], style: .alert)
    }
}

//MARK: UICollectionViewDataSource
extension FolderDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return medias.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddImageCollectionViewCell",
                                                          for: indexPath) as! AddImageCollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell",
                                                          for: indexPath) as! ImageCollectionViewCell
            cell.imageView.image = medias[indexPath.row - 1].thumbImage
            cell.pickIconImage.isHidden = true
            if isEdit && indexPickArr.contains(indexPath.row) {
                cell.pickIconImage.isHidden = false
            }
            if medias[indexPath.row - 1].duration != 0 {
                cell.durationLabel.text = medias[indexPath.row - 1].duration.durationFromSeconds()
                cell.durationLabel.isHidden = false
            } else {
                cell.durationLabel.isHidden = true
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEdit {
            if indexPath.row == 0 {return}
            if indexPickArr.contains(indexPath.row) {
                let index = indexPickArr.index(of: indexPath.row)!
                indexPickArr.remove(at: index)
            } else {
                indexPickArr.append(indexPath.row)
            }
            collectionView.reloadData()
            return
        }
        if indexPath.row == 0 {
            onAddImage()
        } else {
            performSegue(withIdentifier: "toFullScreen", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?[0] else {return}
        weak var imageContainerVC = segue.destination as? ImageContainerViewController
        imageContainerVC?.medias = medias
        imageContainerVC?.index = indexPath.row - 1
        imageContainerVC?.delegate = self
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension FolderDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edge = (self.collectionView.bounds.width - itemInsets.left * 4) / 3
        return CGSize(width: edge, height: edge)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return itemInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemInsets.left
    }
}

//MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension FolderDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /* only camera mode, choose photo from library at bottom of file */
    func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            picker.cameraCaptureMode = .photo
            picker.cameraCaptureMode = .video
            picker.modalPresentationStyle = .fullScreen
            picker.popoverPresentationController?.sourceView = view
            let midX = view.bounds.midX
            let midY = view.bounds.midY
            picker.popoverPresentationController?.sourceRect = CGRect(x: midX, y: midY, width: 0, height: 0)
            present(picker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }
    
    func noCamera() {
        basicAlertWithTitle(nil, message: "Your device don't access to open Camera")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.showHUD()
        let imageURL = info[UIImagePickerControllerReferenceURL] as? URL
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            saveImage(imageURL: imageURL, image, isDelete: true)
        } else {
            guard let videoURL = info[UIImagePickerControllerMediaURL] as? URL else {return}
            var result: PHFetchResult<PHAsset>?
            if let imageURL = imageURL {
                result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            }
            let phAsset = result?.firstObject
            saveVideo(videoURL: videoURL, phAsset: phAsset, isDelete: true)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveImage(imageURL: URL?, _ image: UIImage, asset: PHAsset? = nil, isDelete: Bool) {
        var sourcePath = ""
        if let imageURL = imageURL {
            sourcePath = imageURL.path
        }
        let name = AddMediaService.getMediaName(isVideo: false, sourcePath: sourcePath)
        let date = AddMediaService.getMediaCreationDate(asset: asset)
        guard let data = UIImageJPEGRepresentation(image, 1) else {return}
        let size = AddMediaService.getMediaSize(data: data)
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        MediaService.shared.addMedia(folderID: folder.id, data: data, path: sourcePath, name: name, size: size, date: date, duration: 0) { [weak self] isSucess in
            self?.hideHUD()
            if isSucess {
                MediaService.shared.medias(ofFolder: (self?.folder.id)!, completion: {[weak self] (medias, success) in
                    self?.allMedias = medias
                    self?.medias = (self?.getCorrectArr())!
                    FolderService.shared.updateFolder(id: (self?.folder.id)!, medias: medias)
                    UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
                })
//                self?.toast(String.addMediaSuccess)
                if isDelete {
                    if let asset = asset {AppService.shared.deleteMediaFromLibrary(asset: asset)}
                }
            } else {
                self?.toast(String.errorMess)
            }
        }
    }
    
    func saveVideo(videoURL: URL, phAsset: PHAsset?, isDelete: Bool) {
        let date = AddMediaService.getMediaCreationDate(asset: phAsset)
        let avAsset = AVAsset(url: videoURL as URL)
        let sourcePath = videoURL.path
        let name = AddMediaService.getMediaName(isVideo: true, sourcePath: sourcePath)
        var data = Data()
        do {
            data = try Data(contentsOf: videoURL, options: .dataReadingMapped)
        } catch {
            print(error.localizedDescription)
        }
        let size = AddMediaService.getMediaSize(data: data)
        let duration = Int(CMTimeGetSeconds(avAsset.duration))
        UIApplication.shared.keyWindow?.isUserInteractionEnabled = false
        MediaService.shared.addMedia(folderID: folder.id, data: data, path: sourcePath, name: name, size: size, date: date, duration: duration) { [weak self] isSucess in
            self?.hideHUD()
            if isSucess {
                MediaService.shared.medias(ofFolder: (self?.folder.id)!, completion: {[weak self] (medias, success) in
                    self?.allMedias = medias
                    self?.medias = (self?.getCorrectArr())!
                    FolderService.shared.updateFolder(id: (self?.folder.id)!, medias: medias)
                    UIApplication.shared.keyWindow?.isUserInteractionEnabled = true
                })
//                self?.toast(String.addMediaSuccess)
                if isDelete {
                    if phAsset != nil {AppService.shared.deleteMediaFromLibrary(asset: phAsset!)}
                }
            } else {
                self?.toast(String.errorMess)
            }
        }
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case SegmentType.all.rawValue:
            medias = allMedias
        case SegmentType.image.rawValue:
            medias = images
        case SegmentType.video.rawValue:
            medias = videos
        default:
            break
        }
    }
    
}

//MARK: ImageDetailViewControllerProtocol
extension FolderDetailViewController: ImageDetailViewControllerProtocol {
    func updateMedias(medias: [Media]) {
        self.medias = medias
        allMedias = medias
        segmentControl.selectedSegmentIndex = 0
    }
}

//MARK: DKImagePickerController
extension FolderDetailViewController {
    func chooseFromLibrary() {
        let pickerController = DKImagePickerController()
        pickerController.assetGroupTypes = [.smartAlbumUserLibrary, .smartAlbumVideos, .smartAlbumFavorites, .smartAlbumSlomoVideos, .albumRegular]
        pickerController.sourceType = .photo
        pickerController.didSelectAssets = {(assets: [DKAsset]) in
            if assets.count == 0 {return}
            else {self.view.showHUD()}
            self.alertToSave(assets: assets)
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    private func saveMediasFromLibrary(assets: [DKAsset], isDelete: Bool) {
        for asset in assets {
            let phAsset = asset.originalAsset
            phAsset?.getURL(completionHandler: { (url) in
                guard let url = url else {return}
                if asset.isVideo {
                    self.saveVideo(videoURL: url, phAsset: phAsset, isDelete: isDelete)
                } else {
                    asset.fetchOriginalImage(true, completeBlock: {(image, _) in
                        guard let image = image else {return}
                        self.saveImage(imageURL: url, image, asset: phAsset, isDelete: isDelete)
                    })
                }
            })
        }
    }
    
    private func alertToSave(assets: [DKAsset]) {
        if UserDefaults.standard.bool(forKey: String.kNeverDeleteMedia) {
            saveMediasFromLibrary(assets: assets, isDelete: false)
            return
        }
        let doNotDelete = UIAlertAction(title: "Don't allow", style: .default, handler: { (_) in
            self.saveMediasFromLibrary(assets: assets, isDelete: false)
        })
        let neverDelete = UIAlertAction(title: "No, Don't ask again", style: .default, handler: { (_) in
            UserDefaults.standard.set(true, forKey: String.kNeverDeleteMedia)
            self.saveMediasFromLibrary(assets: assets, isDelete: false)
        })
        let delete = UIAlertAction(title: "Delete", style: .cancel, handler: { (_) in
            self.saveMediasFromLibrary(assets: assets, isDelete: true)
        })
        let actionArr = [doNotDelete, neverDelete, delete]
        let alertController = UIAlertController(title: "Do you want to delete \(assets.count) media/medias from this device? ",
                                                message: nil,
                                                preferredStyle: .alert)
        for action in actionArr {
            alertController.addAction(action)
        }
        present(alertController, animated: true, completion: nil)
    }
}
