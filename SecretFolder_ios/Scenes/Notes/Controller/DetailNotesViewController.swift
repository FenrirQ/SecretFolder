//
//  DetailNotesViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/24/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class DetailNotesViewController: BaseViewController {
    
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var textView: UITextView!
    var textField = UITextField()
    var note: Note?
    var isEdit: Bool!
    var delegate: AddNewNoteProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        if !isEdit {
            textView.text = ""
            textField.text = ""
            customNavigationBar()
            return
        }
        self.showHUD()
        NoteService.shared.loadContent(name: note?.name ?? "") { (content) in
            if content.isEmpty {
                self.hideHUD()
                self.toast(String.errorMess)
            } else {
                self.textView.text = content
                NotificationCenter.default.post(name: NotificationKey.sendNoteContent,
                                                object: nil,
                                                userInfo: [String.contentInfoKey : content])
                self.hideHUD()
            }
        }
    }
    
    func addNotiObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(donePress),
                                               name: NotificationKey.doneEditNote,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(focusTextView),
                                               name: NotificationKey.returnKeyTextFieldNote,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if textView.text.isEmpty {
            if isEdit {
                NoteService.shared.deleteNote(note: note!, completion: { (_) in })
            }
        } else if isEdit {
            let content: String = textView.text
            NotificationCenter.default.post(name: NotificationKey.updateNote,
                                            object: nil,
                                            userInfo: [String.noteInfoKey : content])
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addNotiObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isEdit {
            NotificationCenter.default.post(name: NotificationKey.setNaviTitleNote,
                                            object: nil,
                                            userInfo: [String.noteInfoKey : note!])
        }
    }
    
    private func customNavigationBar() {        /* custom bar when user swipe page view */
        let titleView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "backWebIcon"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(dismissController))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissController))
        let heightNavigation = navigationController?.navigationBar.frame.height
        titleView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: heightNavigation!)
        navigationItem.titleView = titleView
        if #available(iOS 8.2, *) {
            textField.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        } else {
            textField.font = UIFont.boldSystemFont(ofSize: 16)
        }
        textField.textColor = AppColor.warmBlack
        textField.borderStyle = .none
        textField.placeholder = "Enter title here..."
        textField.textAlignment = .center
        textField.returnKeyType = .done
        textField.delegate = self
        titleView.addSubview(textField)
        textField.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
            maker.bottom.equalToSuperview()
        }
    }
    
    @objc func dismissController() {
        if !textView.text.isEmpty && textField.text != "" {
            let date = Date().getDateForNote()
            self.showHUD()
            NoteService.shared.addNote(title: textField.text!, content: textView.text, date: date, completion: { (isSuccess) in
                self.hideHUD()
                self.dismiss(animated: true, completion: nil)
                if !isSuccess {
                    self.delegate?.didFailAddNote()
                }
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func donePress(_ noti: Notification) {
        textView.resignFirstResponder()
        guard let note = note else {return}
        guard let dict = noti.userInfo else {return}
        guard let title = dict["title"] as? String else {return}
        if textView.text.isEmpty {
            toast("Content must not be empty")
            return
        }
        NoteService.shared.updateNote(id: note.id, name: note.name, newTitle: title, content: textView.text)
    }
    
    @objc func focusTextView() {
        textView.becomeFirstResponder()
    }
}

extension DetailNotesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textView.becomeFirstResponder()
        return true
    }
}

protocol AddNewNoteProtocol {
    func didFailAddNote()
}
