//
//  BasePageModelController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/11/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class BasePageModelController: NSObject, UIPageViewControllerDataSource {
    
    var viewControllers: [UIViewController]!
    
    init(viewControllers: [UIViewController]) {
        super.init()
        self.viewControllers = viewControllers
    }
    
    /* Get Data View Controller for the given index */
    func viewControllerAt(index: Int) -> UIViewController? {
        if self.viewControllers.count == 0 || index >= self.viewControllers.count || index < 0 || index == NSNotFound {
            return nil
        }
        return viewControllers[index]
    }
    
    /* get index of any view controller in viewControllers array */
    func indexOf(viewController: UIViewController) -> Int {
        return viewControllers.index(of: viewController) ?? NSNotFound
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = indexOf(viewController: viewController)
        return viewControllerAt(index: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = indexOf(viewController: viewController)
        return viewControllerAt(index: index + 1)
    }
}
