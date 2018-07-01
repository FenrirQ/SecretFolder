//
//  MoreAppViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 1/30/18.
//  Copyright © 2018 FenrirQ. All rights reserved.
//

import UIKit

class MoreAppViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topContentViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var footerToBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightFooterViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!
    
    var appsArr: [MoreAppObject] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var collectionViewLayout: LGHorizontalLinearFlowLayout!
    var sizeForItem: CGSize!
    var pageWidth: CGFloat {
        return self.collectionViewLayout.itemSize.width + self.collectionViewLayout.minimumLineSpacing
    }
    var contentOffset: CGFloat {
        return self.collectionView.contentOffset.x + self.collectionView.contentInset.left
    }
    var apiService = MoreAppService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "MoreAppCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "MoreAppCollectionViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        setupCollectionView()
        apiService.getMoreApp { (objects) in
            self.appsArr = objects
            self.updateItemCenter()
        }
    }
    
    func setupCollectionView() {
        self.heightFooterViewConstraint.constant = Ultilities.makeDistanceValue(44, 48, 50, 52, 76)
        self.footerToBottomConstraint.constant = Ultilities.makeDistanceValue(30, 50, 70, 80, 120)
        let leftSection = Ultilities.makeDistanceValue(22, 22, 22, 22, 50)
        let screenSize = UIScreen.main.bounds.size
        actionButton.cornerRadius = heightFooterViewConstraint.constant / 2
        sizeForItem = CGSize(width: screenSize.width - 2 * leftSection,
                             height: collectionView.bounds.height - 40)
        let leftInsetCollectionView = screenSize.width / 2 - sizeForItem.width / 2 - leftSection
        let spacing: CGFloat = 10
        collectionViewLayout = LGHorizontalLinearFlowLayout(configuredWith: collectionView,
                                                            itemSize: sizeForItem,
                                                            minimumLineSpacing: spacing)
        self.collectionViewLayout.sectionInset = UIEdgeInsetsMake(0, -leftInsetCollectionView, 0, 0)
        self.collectionViewLayout.scaleItems = false
    }
    
    func updateItemCenter() {
        let indexPage = Int(contentOffset / pageWidth)
        let customURL = appsArr[indexPage].customURL
        if UIApplication.shared.canOpenURL(URL(fileURLWithPath: customURL)) {
            self.actionButton.setTitle("OPEN", for: .normal)
        } else {
            self.actionButton.setTitle("FREE", for: .normal)
        }
    }
    
    @IBAction func onActionButton(_ sender: UIButton) {
        if appsArr.isEmpty {return}
        let indexPage = Int(contentOffset / pageWidth)
        let customURL = appsArr[indexPage].customURL
        let linkURL = appsArr[indexPage].linkURL
        if UIApplication.shared.canOpenURL(URL(string: customURL)!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: customURL)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: customURL)!)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: linkURL)!, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(URL(string: linkURL)!)
            }
        }
    }

    @IBAction func onClose(_ sender: UIButton) {
        let previousIndex = UserDefaults.standard.integer(forKey: String.kIndexOfTabbarItem)
        RootTabbarViewController.vc.selectedIndex = previousIndex
        dismiss(animated: true, completion: nil)
    }
}

extension MoreAppViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoreAppCollectionViewCell",
                                                            for: indexPath) as? MoreAppCollectionViewCell
            else {return UICollectionViewCell()}
        cell.configData(appsArr[indexPath.row])
        cell.delegate = self
        return cell
    }
}

extension MoreAppViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateItemCenter()
    }
}

extension MoreAppViewController: MoreAppCollectionViewCellDelegate {
    func moreAppCollectionView(_ cell: UICollectionViewCell, didTapOnCover: UIButton) {
        if let cell = cell as? MoreAppCollectionViewCell {
            if let indexPath = collectionView.indexPath(for: cell) {
                let customURL = appsArr[indexPath.row].customURL
                let linkURL = appsArr[indexPath.row].linkURL
                if UIApplication.shared.canOpenURL(URL(string: customURL)!) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: customURL)!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: customURL)!)
                    }
                } else {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(URL(string: linkURL)!, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(URL(string: linkURL)!)
                    }
                }
            }
        }
    }
}
