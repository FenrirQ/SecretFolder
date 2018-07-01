//
//  DetailNotesContainerViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/12/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class DetailNotesContainerViewController: BaseViewController {

    var index: Int!
    var textField = UITextField()
    var currentNote: Note!
    var content: String!
    override var isAdAtBottom: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(finishEdit))
        let titleView = UIView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func loadView() {
        super.loadView()
        registerNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? DetailNotesPageViewController {
            pageVC.index = self.index
        }
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadContent),
                                               name: NotificationKey.sendNoteContent,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setNavigationTitle),
                                               name: NotificationKey.setNaviTitleNote,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNote),
                                               name: NotificationKey.updateNote,
                                               object: nil)
    }
    
    @objc func loadContent(_ noti: Notification) {
        guard let dict = noti.userInfo else {return}
        guard let content = dict[String.contentInfoKey] as? String else {return}
        self.content = content
    }
    
    @objc func setNavigationTitle(_ noti: Notification) {
        guard let dict = noti.userInfo else {return}
        guard let note = dict[String.noteInfoKey] as? Note else {return}
        self.currentNote = note
        customNavigationBar(with: note)
    }
    
    private func customNavigationBar(with note: Note?) {        /* custom bar when user swipe page view */
        textField.text = note?.title ?? ""
    }
    
    @objc func finishEdit() {
        if textField.text == "" {
            toast("The tile must not be empty")
            return
        }
        NotificationCenter.default.post(name: NotificationKey.doneEditNote, object: nil, userInfo: ["title" : textField.text!])
        textField.resignFirstResponder()
    }
    
    @objc func updateNote(_ noti: Notification) {
        var title = ""
        guard let dict = noti.userInfo else {return}
        guard let content = dict[String.noteInfoKey] as? String else {return}
        if textField.text == "" {
            return
        } else {
            title = textField.text!
        }
        NoteService.shared.updateNote(id: currentNote.id, name: currentNote.name, newTitle: title, content: content)
    }
    @IBAction func onDelete(_ sender: UIButton) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            self.showHUD()
            NoteService.shared.deleteNote(note: self.currentNote) { (success) in
                if success {
                    self.hideHUD()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.toast(String.errorMess)
                }
            }
        }
        showAlertView(title: "Confirm",
                      message: "Are you sure to delete this file?",
                      actions: [okAction],
                      style: .alert)
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        if !content.isEmpty {
            share(items: [content])
        } else {
            toast("Note is empty")
        }
    }
}

extension DetailNotesContainerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: NotificationKey.returnKeyTextFieldNote, object: nil, userInfo: nil)
        return true
    }
}
