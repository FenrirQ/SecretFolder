//
//  DetailNotesPageViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/12/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class DetailNotesPageViewController: UIPageViewController {
    
    var notes: [Note] = NoteService.shared.notes
    var index: Int!
    var modelController: BasePageModelController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllers = initViewControllers()
        modelController = BasePageModelController(viewControllers: viewControllers)
        self.dataSource = modelController
        if let startingController: UIViewController = modelController.viewControllerAt(index: index) {
            setViewControllers([startingController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    func initViewControllers() -> [UIViewController] {
        var viewControllers: [UIViewController] = []
        for note in notes {
            let noteVC = DetailNotesViewController.initWithNib()
            noteVC.note = note
            noteVC.isEdit = true
            viewControllers.append(noteVC)
        }
        return viewControllers
    }
}
