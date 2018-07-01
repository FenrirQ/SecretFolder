//
//  ContactsViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ContactsViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButtonTopContraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isEdit: Bool = false { /* check when user want to delete multiple items */
        didSet {
            if isEdit {
                deleteButtonTopContraint.constant = -deleteButton.bounds.height - 10
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            } else {
                deleteButtonTopContraint.constant = 150
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            }
        }
    }
    var selectedRows: [Int] = []  /* array contains all selected items index */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settingIcon").withRenderingMode(.alwaysOriginal),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(showSettingVC))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onEdit))
        tableView.allowsMultipleSelection = true
    }
    
    @objc func onEdit() {
        isEdit = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onDone))
        tableView.reloadData() //hide all edit button of every cell
    }
    
    @objc func onDone() {
        isEdit = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(onEdit))
        selectedRows = []
        tableView.reloadData()
    }
    
    @objc func showSettingVC() {
        showSettingsVCFromCurrentController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    /* show action sheet when tap edit of every cell */
    @IBAction func onAddContact(_ sender: UIButton) {
        let importAction = UIAlertAction(title: "Import Contact", style: .default) { (_) in
            if #available(iOS 9.0, *) {
                self.importContact()
            } else {
                // Fallback on earlier versions
            }
        }
        let createAction = UIAlertAction(title: "Create New", style: .default) { (_) in
            let storyBoard : UIStoryboard = UIStoryboard(name: "ContactsViewController", bundle:nil)
            weak var detailVC: ContactDetailViewController? = storyBoard.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController
            detailVC?.mode = .new
            self.navigationController?.pushViewController(detailVC!, animated: true)
        }
        showAlertView(title: nil, message: nil, actions: [importAction, createAction], style: .actionSheet)
    }
    
    
    /* import contact from app contact of device action alert */
    @available(iOS 9.0, *)
    func importContact() {
        let entityType = CNEntityType.contacts
        let authStatus = CNContactStore.authorizationStatus(for: entityType)
        if authStatus == CNAuthorizationStatus.notDetermined {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: entityType, completionHandler: { (success, nil) in
                if success {
                    self.openContactOfDevice()
                } else {
                    print("not authorized")
                }
            })
        } else if authStatus == CNAuthorizationStatus.authorized {
            openContactOfDevice()
        }
    }
    
    /* present contact view controller of device */
    @available(iOS 9.0, *)
    func openContactOfDevice() {
        let contactPickerViewController = CNContactPickerViewController()
        contactPickerViewController.delegate = self
        present(contactPickerViewController, animated: true, completion: nil)
    }
    
    /* action delete multiple items */
    @IBAction func onDeleteTool(_ sender: UIButton) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            var contactsToDelete: [Contact] = []
            for index in self.selectedRows {
                contactsToDelete.append(ContactService.shared.contacts[index])
            }
            for contact in contactsToDelete {
                ContactService.shared.deleteContact(contact: contact, completion: { (_) in
                    self.tableView.reloadData()
                })
            }
            self.onDone()
        }
        showAlertView(title: "Confirm",
                      message: "Are you sure to delete these contacts?",
                      actions: [okAction],
                      style: .alert)
    }
    
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactService.shared.contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell", for: indexPath)
            as! ContactsTableViewCell
        let contact = ContactService.shared.contacts[indexPath.row]
        cell.nameLabel.text = contact.name
        if let imageData = contact.imageData {
            cell.iconImage.image = UIImage(data: imageData, scale: 1)
        }
        cell.delegate = self
        /* when user tap on edit button item right bar to delete multiple items */
        if isEdit {
            cell.editButton.isHidden = true
            cell.emptyCircle.isHidden = false
            cell.pickImage.isHidden = selectedRows.contains(indexPath.row) ? false : true
        } else {
            cell.editButton.isHidden = false
            cell.emptyCircle.isHidden = true
            cell.pickImage.isHidden = true
        }
        return cell
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /* mode user tap edit button right bar to delete multiple items */
        if isEdit {
            if selectedRows.contains(indexPath.row) {
                let index = selectedRows.index(of: indexPath.row)!
                selectedRows.remove(at: index)
            } else {
                selectedRows.append(indexPath.row)
            }
            tableView.reloadData()
            return
        }
        /* else */
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "ContactsViewController", bundle:nil)
        weak var detailVC: ContactDetailViewController? = storyBoard.instantiateViewController(withIdentifier: "ContactDetailViewController") as? ContactDetailViewController
        detailVC?.mode = .detail
        detailVC?.contact = ContactService.shared.contacts[indexPath.row]
        detailVC?.indexPath = indexPath
        self.navigationController?.pushViewController(detailVC!, animated: true)
    }
}

extension ContactsViewController: ContactsTableViewCellProtocol {
    /* tap three dot on every cell */
    func contactsTableViewCell(_ cell: UITableViewCell, didTapOnEdit sender: UIButton) {
        if let indexPath = tableView.indexPath(for: cell) {
            let deleteAction = UIAlertAction(title: String.delete, style: .default) { (_) in
                self.onDelete(indexPath: indexPath)
            }
            showAlertView(title: nil, message: nil, actions: [deleteAction], style: .actionSheet)
        }
    }
    
    /* action in action sheet above */
    private func onDelete(indexPath: IndexPath) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            ContactService.shared.deleteContact(contact: ContactService.shared.contacts[indexPath.row], completion: { (success) in
                if success {
                    self.toast(String.deleteSuccess)
                    self.tableView.reloadData()
                } else {
                    self.toast(String.errorMess)
                }
            })
        }
        showAlertView(title: "Confirm",
                      message: "Are you sure to delete this contact?",
                      actions: [okAction],
                      style: .alert)
    }
}

extension ContactsViewController: CNContactPickerDelegate {
    @available(iOS 9.0, *)
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let name = "\(contact.givenName)\(" " + contact.middleName) \(contact.familyName)"
        if isExistContact(name: name) {
            toast("This contact has existed")
            return
        }
        let imageData = contact.imageData
        let phone1 = ((contact.phoneNumbers[0].value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue") as! String
        var phone2 = ""
        if contact.phoneNumbers.count > 1 {
            phone2 = ((contact.phoneNumbers[0].value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject).value(forKey: "stringValue") as! String
        }
        var birthday = ""
        if let day = contact.birthday?.day, let month = contact.birthday?.month, let year = contact.birthday?.year {
            birthday = "\(month)/\(day)/\(year)"
        }
        var email = ""
        if let emailAdress = contact.emailAddresses.first {
            email = ((emailAdress.value(forKey: "labelValuePair") as AnyObject).value(forKey: "value") as AnyObject) as! String
        }
        let sucess = ContactService.shared.saveContact(name: name,
                                                       phone1: phone1,
                                                       phone2: phone2,
                                                       birthday: birthday,
                                                       email: email,
                                                       imageData: imageData)
        if sucess {
            toast(String.importContactSuccess)
            tableView.reloadData()
        } else {
            toast(String.errorMess)
        }
    }

    @available(iOS 9.0, *)
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func isExistContact(name: String) -> Bool {
        for contact in ContactService.shared.contacts {
            if contact.name == name {return true}
        }
        return false
    }
}

