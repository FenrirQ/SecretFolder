//
//  ContainerViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 12/20/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

class ContainerViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancelIcon"), style: .plain, target: self, action: #selector(dismissSettings))
    }
    
    @objc func dismissSettings() {
        dismiss(animated: true, completion: nil)
    }
}
