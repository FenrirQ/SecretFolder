//
//  ImageDetailPageViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/11/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class ImageDetailPageViewController: UIPageViewController {
    
    var medias: [Media]!
    var index: Int!
    var modelController: BasePageModelController!
    
    override func viewDidLoad() {
        let viewControllers = initViewControllers()
        modelController = BasePageModelController(viewControllers: viewControllers)
        self.dataSource = modelController
        if let startingController: UIViewController = modelController.viewControllerAt(index: index) {
            setViewControllers([startingController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func initViewControllers() -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        for media in medias {
            let imageVC = ImageDetailViewController.initWithNib()
            imageVC.media = media
            viewControllers.append(imageVC)
        }
        return viewControllers
    }
}
