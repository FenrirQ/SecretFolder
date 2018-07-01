//
//  ViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class StorageViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Storage"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settingIcon").withRenderingMode(.alwaysOriginal),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showSettingVC))
    }
    
    @objc func showSettingVC() {
        showSettingsVCFromCurrentController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        weak var folderDetailVC = segue.destination as? FolderDetailViewController
        guard let indexPath = tableView.indexPathForSelectedRow else {return}
        folderDetailVC?.folder = FolderService.shared.folders[indexPath.row]
    }
    
    @IBAction func addAction(_ sender: UIButton) {
        var alertController = UIAlertController()
        let saveAction = UIAlertAction(title: String.save, style: .default) { (_) in
            let name = alertController.textFields?[0].text ?? ""
            FolderService.shared.createFolder(name: name, completion: { (success) in
                if success {
                    self.tableView.reloadData()
                    self.toast(String.createFolderSuccess)
                } else {
                    self.toast(String.errorMess)
                }
            })
        }
        alertController = showAlertViewWithTextField(title: "New album",
                             message: "Enter name for this album",
                             actions: [saveAction],
                             placeHolder: "Enter name here")
    }
    
}

//MARK: UITableViewDataSource
extension StorageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FolderService.shared.folders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StorageTableViewCell", for: indexPath)
            as? StorageTableViewCell else {return UITableViewCell()}
        let folder = FolderService.shared.folders[indexPath.row]
        cell.titleFolder.text = folder.name
        cell.amountLabel.text = String(folder.amount) + " file(s)"
        cell.sizeLabel.text = String(folder.size) + " MB"
        cell.delegate = self
        return cell
    }
    
}

//MARK: UITableViewDelegate
extension StorageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: Storage Table View Cell Delegate
extension StorageViewController: StorageTableViewCellDelegate {
    func storageTableViewCell(_ cell: StorageTableViewCell, didTapOnEdit sender: UIButton) {
        if let indexPath = tableView.indexPath(for: cell) {
            let folder = FolderService.shared.folders[indexPath.row]
            let editAction = UIAlertAction(title: String.edit, style: .default, handler: { (_) in
                self.editAction(folder: folder)
            })
            let deleteAction = UIAlertAction(title: String.delete, style: .default, handler: { (_) in
                self.deleteAction(folder: folder)
            })
            showAlertView(title: nil, message: nil, actions: [editAction, deleteAction], style: .actionSheet)
        }
    }
    
    func editAction(folder: Folder) {
        var alert = UIAlertController()
        let saveAction = UIAlertAction(title: String.save, style: .default, handler: { (_) in
            let newName = alert.textFields?[0].text ?? ""
            FolderService.shared.editFolder(id: folder.id, name: newName, completion: { (success) in
                if success {
                    self.tableView.reloadData()
                    self.toast(String.editFolderSuccess)
                } else {
                    self.toast(String.errorMess)
                }
            })
        })
        alert = self.showAlertViewWithTextField(title: folder.name,
                                                message: "Enter new name",
                                                actions: [saveAction],
                                                placeHolder: "Enter new name here")
    }
    
    func deleteAction(folder: Folder) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            self.showHUD()
            FolderService.shared.deleteFolder(id: folder.id) { (success) in
                self.hideHUD()
                if success {
                    self.tableView.reloadData()
                    self.toast(String.deleteSuccess)
                } else {
                    self.toast(String.errorMess)
                }
            }
        }
        showAlertView(title: "Confirm",
                      message: "Are you sure to delete this folder?",
                      actions: [okAction],
                      style: .alert)
    }
}
