//
//  ContactDetailViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/8/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import MessageUI

class ContactDetailViewController: BaseViewController {

    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNum1TextField: UITextField!
    @IBOutlet weak var callButton1: UIButton!
    @IBOutlet weak var messButton1: UIButton!
    @IBOutlet weak var phoneNum2TextField: UITextField!
    @IBOutlet weak var callButton2: UIButton!
    @IBOutlet weak var messButton2: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet var chooseImageGesture: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var mode: ContactMode?
    var contact: Contact?
    var indexPath: IndexPath?               /* indexPath of selected cell in table view */
    let picker = UIImagePickerController()
    var maxContentOffset: CGPoint! {
        get {
            return CGPoint(x: 0, y: scrollView.contentSize.height - view.bounds.height)
        }
    }
    override var isAdAtBottom: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        correctMode()
        phoneNum1TextField.keyboardType = .numberPad
        phoneNum2TextField.keyboardType = .numberPad
        nameTextField.delegate = self
        phoneNum1TextField.delegate = self
        phoneNum2TextField.delegate = self
        emailTextField.delegate = self
        scrollView.keyboardDismissMode = .onDrag
        registerNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name:NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name:NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showBannerWhenDatePickerDismiss),
                                               name: NotificationKey.dateSelectionDidDismiss,
                                               object: nil)   //when picker dismiss, RMDateSelection lib push notification
    }

    @objc func showBannerWhenDatePickerDismiss() {
        showAdBanner()
    }
    
    @IBAction func onPickDate(_ sender: UIButton) {
        setupPickerView()
        setupForEdit()
        CustomAdsService.hideAdBanner()
    }
    
    func setupPickerView() {   /* config birthday picker view */
        let style = RMActionControllerStyle.white
        let selectAction = RMAction<UIDatePicker>(title: "Done", style: .done) { (controller) in
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "MM/dd/yyyy"
            self.birthdayLabel.text = dateFormater.string(from: controller.contentView.date)
        }
        let cancelAction = RMAction<UIDatePicker>(title: "Cancel", style: .cancel, andHandler: nil)
        let actionController = RMDateSelectionViewController(style: style,
                                                             title: nil,
                                                             message: String.pickBirthdayMess,
                                                             select: selectAction,
                                                             andCancel: cancelAction)
        actionController?.datePicker.datePickerMode = .date
        actionController?.datePicker.date = Date()
        present(actionController!, animated: true, completion: nil)
    }
    
    /* custom view controller with correct mode */
    func correctMode() {
        guard let mode = mode else {return}
        switch mode {
        case .detail:
            setupForDetail()
        case .edit:
            setupForEdit()
        case .new:
            setupForNew()
        }
    }
    
    /* edit contact */
    func setupForEdit() {
        self.title = "Edit Contact"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDone))
        
        chooseImageGesture.isEnabled = true

        callButton1.isHidden = true
        messButton1.isHidden = true
        
        callButton2.isHidden = true
        messButton2.isHidden = true
    }
    
    /* show detail contact */
    func setupForDetail() {
        self.title = "Detail"
        navigationItem.rightBarButtonItem = nil
        guard let contact = contact else {
            toast(String.errorMess)
            navigationController?.popViewController(animated: true)
            return
        }
        chooseImageGesture.isEnabled = true
        
        nameTextField.text = contact.name
        
        callButton1.isHidden = false
        messButton1.isHidden = false
        phoneNum1TextField.text = contact.phone1
        
        callButton2.isHidden = false
        messButton2.isHidden = false
        phoneNum2TextField.text = contact.phone2
        
        birthdayLabel.text = contact.birthday
        
        emailTextField.text = contact.email
        
        if let imageData = contact.imageData {
            avatarImage.image = UIImage(data: imageData, scale: 1)
        }
    }
    
    /* create new contact */
    func setupForNew() {
        self.title = "New contact"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDone))
        
        chooseImageGesture.isEnabled = true
        
        nameTextField.text = ""
        nameTextField.customPlaceholder("Enter name here", size: 15)
        
        phoneNum1TextField.text = ""
        phoneNum1TextField.customPlaceholder("Enter first phone number here", size: 15)
        callButton1.isHidden = true
        messButton1.isHidden = true
        
        phoneNum2TextField.text = ""
        phoneNum2TextField.customPlaceholder("Enter second phone number here", size: 15)
        callButton2.isHidden = true
        messButton2.isHidden = true
        
        birthdayLabel.text = ""
        
        emailTextField.text = ""
        emailTextField.customPlaceholder("Enter email here", size: 15)
    }
    
    @objc func onDone() {
        let name = nameTextField.text ?? ""
        let phoneNumber1 = phoneNum1TextField.text ?? ""
        let phoneNumber2 = phoneNum2TextField.text ?? ""
        let birthday = birthdayLabel.text ?? ""
        let email = emailTextField.text ?? ""
        var imageData: Data?
        if (avatarImage.image?.isEqual(to: #imageLiteral(resourceName: "avatarBackground")))! {
            imageData = nil
        } else {
            imageData = UIImageJPEGRepresentation(avatarImage.image!, 1)
        }
        if mode == ContactMode.new || mode == ContactMode.edit {
            for contact in ContactService.shared.contacts {
                if let thisContact = self.contact {  //on edit mode
                    if thisContact.name == name {break}  //didn't edit name
                    if (thisContact.name != name && contact.name == name) {  //edited name and new name was existed
                        toast("This name has existed")
                        return
                    }
                }
                if name == contact.name {
                    toast("This name has existed")
                    return
                }
            }
        }
        switch isQualify() {
        case .noError:
            var success: Bool!
            if mode == ContactMode.new {
                success = ContactService.shared.saveContact(name: name,
                                                            phone1: phoneNumber1,
                                                            phone2: phoneNumber2,
                                                            birthday: birthday,
                                                            email: email,
                                                            imageData: imageData)
                navigationController?.popViewController(animated: true)
                return
            } else {
                success = ContactService.shared.updateContact(oldName: contact!.name,
                                                              newName: name,
                                                              phone1: phoneNumber1,
                                                              phone2: phoneNumber2,
                                                              birthday: birthday,
                                                              email: email,
                                                              imageData: imageData)
            }
            if success {
                guard let indexPath = self.indexPath else {return}      /* indexPath of row selected in tableView */
                contact = ContactService.shared.contacts[indexPath.row]
                nameTextField.resignFirstResponder()
                phoneNum1TextField.resignFirstResponder()
                phoneNum2TextField.resignFirstResponder()
                emailTextField.resignFirstResponder()
                setupForDetail()
            } else {
                toast(String.errorMess)
            }
        case .lackInfo:
            toast("Please complete the information")
        case .invalidEmail:
            toast("Invalid email")
        }
    }
    
    func onEdit() {
        setupForEdit()
        mode = .edit
    }
    
    private func isQualify() -> ContactError {
        let name = nameTextField.text ?? ""
        let phoneNumber1 = phoneNum1TextField.text ?? ""
        let email = emailTextField.text ?? ""
        if name.isEmpty {
            return .lackInfo
        }
        if phoneNumber1.isEmpty {
            return .lackInfo
        }
        if !email.isEmpty && !email.isEmail() {
            return .invalidEmail
        }
        return .noError
    }
    
    @IBAction func onChooseImage(_ sender: UITapGestureRecognizer) {
        setupForEdit()
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
    
    @IBAction func onCall(_ sender: UIButton) {
        var phoneNumber = ""
        if sender.tag == 101 {
            phoneNumber = contact!.phone1
        }
        if sender.tag == 103 {
            if !contact!.phone2.isEmpty {
                phoneNumber = contact!.phone2
            } else {
                toast(String.phoneNumberEmpty)
                return
            }
        }
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func onMess(_ sender: UIButton) {
        var phoneNumber = ""
        if sender.tag == 102 {
            phoneNumber = contact!.phone1
        }
        if sender.tag == 104 && !contact!.phone2.isEmpty {
            phoneNumber = contact!.phone2
        }
        if phoneNumber.isEmpty {
            toast(String.phoneNumberEmpty)
            return
        }
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        let messageVC = MFMessageComposeViewController()
        messageVC.body = ""
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        present(messageVC, animated: true, completion: nil)
    }
    
    
}

//MARK: ImagePickerDelegate
extension ContactDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseFromLibrary() {
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.modalPresentationStyle = .fullScreen
        picker.popoverPresentationController?.sourceView = view
        let midX = view.bounds.midX
        let midY = view.bounds.midY
        picker.popoverPresentationController?.sourceRect = CGRect(x: midX, y: midY, width: 0, height: 0)
        present(picker, animated: true, completion: nil)
    }
    
    func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
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
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let avatarImage = selectedImage.thumbImage(with: 150)
        self.avatarImage.image = avatarImage
        dismiss(animated: true, completion: nil)
    }
}

//MARK: MFMessageComposeViewControllerDelegate
extension ContactDetailViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled:
            toast("Message was cancelled")
        case .failed:
            toast("Message failed")
        case .sent:
            toast("Message sent")
        }
        dismiss(animated: true, completion: nil)
    }
}

//MARK: UITextFieldDelegate
extension ContactDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if mode == .detail || mode == .edit {
            onEdit()
        } else {
            onEdit()
            mode = .new
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* scroll view scroll when keyboard shows and hides */
    @objc func keyboardWillShow(_ notification: Notification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}

