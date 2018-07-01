//
//  SecurityCodeViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/21/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class SecurityCodeViewController: BaseViewController {

    @IBOutlet weak var passDot1: UIView!
    @IBOutlet weak var passDot2: UIView!
    @IBOutlet weak var passDot3: UIView!
    @IBOutlet weak var passDot4: UIView!
    
    var passArray: [Int] = []
    var dotArray: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dotArray = [passDot1, passDot2, passDot3, passDot4]
        self.title = "Set Pass Code"
    }
    
    @IBAction func onNumberButton(_ sender: UIButton) {
        if passArray.count >= 4 {
            return
        } else if passArray.count == 3 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(onSave))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        guard let title = sender.titleLabel?.text else {return}
        guard let number = Int(title) else {return}
        passArray.append(number)
        for i in 0...(passArray.count - 1) {
            dotArray[i].backgroundColor = AppColor.appOrange
        }
    }
    
    @IBAction func onBackspaceButton(_ sender: UIButton) {
        if passArray.count <= 0 {return}
        passArray.remove(at: passArray.count - 1)
        dotArray[passArray.count].backgroundColor = UIColor.colorFromHexa("D8D8D8")
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc func onSave() {
        let pass = "\(passArray[0])\(passArray[1])\(passArray[2])\(passArray[3])"
        UserDefaults.standard.set(pass, forKey: String.kPassCode)
        UserDefaults.standard.set(CellType.securityCode.indexPath.row, forKey: String.kLockType)
        NotificationCenter.default.post(name: NotificationKey.checkLockType, object: nil)
        toast(String.setPassCodeSuccess)
        navigationController?.popViewController(animated: true)
    }

}
