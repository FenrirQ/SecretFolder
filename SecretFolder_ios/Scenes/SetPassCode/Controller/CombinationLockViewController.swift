//
//  CombinationLockViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/21/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class CombinationLockViewController: BaseViewController {

    @IBOutlet weak var passPickerView: UIPickerView!
    
    let dataSize = 100000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Set Pass Code"
        for i in 0...3 {
            passPickerView.selectRow(dataSize / 2, inComponent: i, animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onSave))
    }
    
    @objc func onSave() {
        var pass = ""
        for i in 0...3 {
            pass = pass + "\(passPickerView.selectedRow(inComponent: i) % 10)"
        }
        UserDefaults.standard.set(pass, forKey: String.kPassCode)
        UserDefaults.standard.set(CellType.combinationLock.indexPath.row, forKey: String.kLockType)
        NotificationCenter.default.post(name: NotificationKey.checkLockType, object: nil)
        toast(String.setPassCodeSuccess)
        navigationController?.popViewController(animated: true)
    }
}

extension CombinationLockViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataSize
    }
    
}

extension CombinationLockViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let color = (row == pickerView.selectedRow(inComponent: component)) ? AppColor.appOrange : AppColor.warmBlack
        return NSAttributedString(string: String(row % 10),
                                  attributes: [NSAttributedStringKey.foregroundColor : color])
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
    }
}
