//
//  SettingsTableViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/20/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadRows),
                                               name: NotificationKey.checkLockType,
                                               object: nil)
    }
    
    @objc private func reloadRows() {
        let indexPaths = [CellType.dotLock.indexPath, CellType.combinationLock.indexPath, CellType.securityCode.indexPath]
        tableView.reloadRows(at: indexPaths, with: .none)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        var title = ""
        switch section {
        case SectionType.upgrade.rawValue:
            title = "upgrade".uppercased()
        case SectionType.lock.rawValue:
            title = "lock type".uppercased()
        case SectionType.passCode.rawValue:
            title = "pass codes".uppercased()
        case SectionType.more.rawValue:
            title = "more".uppercased()
        default:
            break
        }
        header.textLabel?.textColor = UIColor.colorFromHexa("8F8E94")
        header.textLabel?.font = UIFont.systemFont(ofSize: 12)
        header.textLabel?.text = title
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath {
        case CellType.upgrade.indexPath:
            purchase()
        case CellType.restore.indexPath:
            restorePurchase()
        case CellType.dotLock.indexPath:
            chooseLockType(.dotLock)
        case CellType.combinationLock.indexPath:
            chooseLockType(.combinationLock)
        case CellType.securityCode.indexPath:
            chooseLockType(.securityCode)
        case CellType.setPass.indexPath:
            setPassCode()
        case CellType.rate.indexPath:
            rateApp()
        case CellType.share.indexPath:
            shareApp()
        case CellType.feedback.indexPath:
            feedback()
        default:
            break
        }
    }
    
    func chooseLockType(_ type: CellType) {
        switch type {
        case .dotLock:
            let dotLockVC = DotLockViewController.initWithNib()
            navigationController?.pushViewController(dotLockVC, animated: true)
        case .combinationLock:
            let combinationLockVC = CombinationLockViewController.initWithNib()
            navigationController?.pushViewController(combinationLockVC, animated: true)
        case .securityCode:
            let securityCodeVC = SecurityCodeViewController.initWithNib()
            navigationController?.pushViewController(securityCodeVC, animated: true)
        default:
            break
        }
    }
    
    func setPassCode() {
        let type = UserDefaults.standard.integer(forKey: String.kLockType)
        switch type {
        case CellType.dotLock.indexPath.row:
            let dotLockVC = DotLockViewController.initWithNib()
            navigationController?.pushViewController(dotLockVC, animated: true)
        case CellType.combinationLock.indexPath.row:
            let combinationLockVC = CombinationLockViewController.initWithNib()
            navigationController?.pushViewController(combinationLockVC, animated: true)
        case CellType.securityCode.indexPath.row:
            let securityCodeVC = SecurityCodeViewController.initWithNib()
            navigationController?.pushViewController(securityCodeVC, animated: true)
        default:
            break
        }
    }
}
