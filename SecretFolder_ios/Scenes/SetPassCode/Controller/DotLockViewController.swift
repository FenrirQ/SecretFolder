//
//  DotLockViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/22/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import CCGestureLock

class DotLockViewController: BaseViewController {

    @IBOutlet weak var dotLockControl: CCGestureLock!
    @IBOutlet weak var cancelButton: UIButton!
    
    var dotPass = [NSNumber]()
    
    var isCancelHidden: Bool! {
        didSet {
            cancelButton.isHidden = isCancelHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Set Pass Code"
        setupGestureLock()
        isCancelHidden = true
    }
    
    private func setupGestureLock() {
        // Set number of sensors
        dotLockControl.lockSize = (3, 3)
        // Sensor grid customisations
        dotLockControl.edgeInsets = UIEdgeInsetsMake(30, 30, 30, 30)
        // Sensor point customisation (normal)
        dotLockControl.setSensorAppearance(type: .inner, radius: 5, width: 10, color: AppColor.lightGray, forState: .normal)
        dotLockControl.setSensorAppearance(type: .outer, color: .blue, forState: .normal)
        // Sensor point customisation (selected)
        dotLockControl.setSensorAppearance(type: .inner, radius: 5, width: 10, color: AppColor.appOrange, forState: .selected)
        dotLockControl.setSensorAppearance(type: .outer, radius: 30, width: 3, color: AppColor.appOrange, forState: .selected)
        // Line connecting sensor points (normal/selected)
        [CCGestureLock.GestureLockState.normal, CCGestureLock.GestureLockState.selected].forEach { (state) in
            dotLockControl.setLineAppearance(
                width: 5.5,
                color: AppColor.appOrange.withAlphaComponent(0.5),
                forState: state
            )
        }
        // Line connection sensor points (wrong password)
        dotLockControl.setLineAppearance(
            width: 5.5,
            color: UIColor.red.withAlphaComponent(0.5),
            forState: .error
        )
        dotLockControl.addTarget(
            self,
            action: #selector(gestureComplete),
            for: .gestureComplete
        )
    }
    
    @objc func gestureComplete(gestureLock: CCGestureLock) {
        dotPass = gestureLock.lockSequence
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(onSave))
        isCancelHidden = false
    }
    
    @objc func onSave() {
        UserDefaults.standard.set(dotPass, forKey: String.kDotPass)
        UserDefaults.standard.set(CellType.dotLock.indexPath.row, forKey: String.kLockType)
        NotificationCenter.default.post(name: NotificationKey.checkLockType, object: nil)
        toast(String.setPassCodeSuccess)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        dotLockControl.gestureLockState = .normal
        navigationItem.rightBarButtonItem = nil
        isCancelHidden = true
    }
    
}
