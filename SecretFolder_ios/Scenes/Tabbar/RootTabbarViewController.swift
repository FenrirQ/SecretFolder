//
//  RootTabbarViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class RootTabbarViewController: UITabBarController {
    lazy var storageVC = StorageViewController.initWithNib()
    lazy var notesVC = NotesViewController.initWithNib()
    lazy var contactsVC = ContactsViewController.initWithNib()
    lazy var browserVC = BrowserViewController.initWithNib()
    lazy var moreVC = PreviousViewController.initWithNib()
    
    var moreItem: UITabBarItem!
    
    static let vc = RootTabbarViewController()
    
    override func viewDidLoad() {
        tabBar.isTranslucent = false
        let storageNav = BaseNavigationController(rootViewController: storageVC)
        self.tabBar.tintColor = AppColor.appOrange
        self.view.backgroundColor = .white
        let storageItem = UITabBarItem(title: "Storage",
                                       image: #imageLiteral(resourceName: "storageIcon"),
                                       selectedImage: #imageLiteral(resourceName: "storageIconActive").withRenderingMode(.alwaysOriginal))
        storageNav.tabBarItem = storageItem
        
        let notesNav = BaseNavigationController(rootViewController: notesVC)
        let notesItem = UITabBarItem(title: "Notes",
                                     image: #imageLiteral(resourceName: "notesIcon"),
                                     selectedImage: #imageLiteral(resourceName: "notesIconActive").withRenderingMode(.alwaysOriginal))
        notesNav.tabBarItem = notesItem
        
        let contactsNav = BaseNavigationController(rootViewController: contactsVC)
        let contactsItem = UITabBarItem(title: "Contacts",
                                        image: #imageLiteral(resourceName: "contactsIcon"),
                                        selectedImage: #imageLiteral(resourceName: "contactsIconActive").withRenderingMode(.alwaysOriginal))
        contactsNav.tabBarItem = contactsItem
        
        let browserItem = UITabBarItem(title: "Browser",
                                       image: #imageLiteral(resourceName: "browserIcon"),
                                       selectedImage: #imageLiteral(resourceName: "browserIconActive").withRenderingMode(.alwaysOriginal))
        browserVC.tabBarItem = browserItem
        
        moreItem = UITabBarItem(title: "More",
                                    image: #imageLiteral(resourceName: "moreAppIcon"),
                                    selectedImage: #imageLiteral(resourceName: "moreAppIconActive").withRenderingMode(.alwaysOriginal))
        moreVC.tabBarItem = moreItem
        
        self.viewControllers = [storageNav, notesNav, contactsNav, browserVC, moreVC]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //check first time and present setpassfirsttimeVC
        if !UserDefaults.standard.bool(forKey: String.kNotFirstTime) {
            let setPassFirstVC = SetPassFirstTimeViewController.initWithNib()
            present(setPassFirstVC, animated: true, completion: nil)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        AppService.shared.checkShowFullAds()
        if item == moreItem {
            guard let root = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController else {return}
            let moreVC = MoreAppViewController.initWithNib()
            root.present(moreVC, animated: true, completion: nil)
        } else {
            guard let index = tabBar.items?.index(of: item) else {return}
            UserDefaults.standard.set(index, forKey: String.kIndexOfTabbarItem)
        }
    }
}
