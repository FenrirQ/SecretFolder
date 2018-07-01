//
//  NotesViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class NotesViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    
    var isEdit: Bool = false {  /* check when user want to delete multiple items */
        didSet {
            if isEdit {
                deleteButtonTopConstraint.constant = -deleteButton.bounds.height - 10
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            } else {
                deleteButtonTopConstraint.constant = 150
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            }
        }
    }
    var selectedRows: [Int] = []  /* array contains all selected items index */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Notes"
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
    
    @IBAction func onDeleteTool(_ sender: UIButton) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            var notesToDelete: [Note] = []
            for index in self.selectedRows {
                notesToDelete.append(NoteService.shared.notes[index])
            }
            for note in notesToDelete {
                NoteService.shared.deleteNote(note: note, completion: { (_) in
                    self.tableView.reloadData()
                })
            }
            self.onDone()
        }
        showAlertView(title: "Confirm",
                      message: "Are you sure to delete these notes?",
                      actions: [okAction],
                      style: .alert)
    }
    
    @IBAction func onAddNewNote(_ sender: UIButton) {
        let noteDetail = DetailNotesViewController.initWithNib()
        noteDetail.isEdit = false
        noteDetail.delegate = self
        let newNoteNavi = BaseNavigationController(rootViewController: noteDetail)
        present(newNoteNavi, animated: true, completion: nil)
    }
    
    
}

extension NotesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NoteService.shared.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
        let note = NoteService.shared.notes[indexPath.row]
        cell.titleLabel.text = note.title
        cell.subLabel.text = "\(note.size) KB \(note.creationDate)"
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

extension NotesViewController: UITableViewDelegate {
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
        /* else  */
        tableView.deselectRow(at: indexPath, animated: true)
        let storyBoard : UIStoryboard = UIStoryboard(name: "NotesViewController", bundle:nil)
        weak var detailContainerVC = storyBoard.instantiateViewController(withIdentifier: "DetailNotesContainerViewController")
            as? DetailNotesContainerViewController
        detailContainerVC?.index = indexPath.row
        navigationController?.pushViewController(detailContainerVC!, animated: true)
    }
}

extension NotesViewController: NotesTableViewCellProtocol {
    func noteTableViewCell(_ cell: UITableViewCell, didTapOnEdit sender: UIButton) {
        if let indexPath = tableView.indexPath(for: cell) {
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { (_) in
                self.onDelete(indexPath: indexPath)
            }
            showAlertView(title: nil, message: nil, actions: [deleteAction], style: .actionSheet)
        }
    }
    
    private func onDelete(indexPath: IndexPath) {
        let okAction = UIAlertAction(title: String.ok, style: .default) { (_) in
            NoteService.shared.deleteNote(note: NoteService.shared.notes[indexPath.row]) { (success) in
                if success {
                    self.toast(String.deleteSuccess)
                    self.tableView.reloadData()
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
}

extension NotesViewController: AddNewNoteProtocol {
    func didFailAddNote() {
        toast("This note's name has existed")
    }
}
