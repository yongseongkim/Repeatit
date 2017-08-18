//
//  MoreViewController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MessageUI
import Carte
import URLNavigator

struct MoreItem {
    let name: String
    let action: (() -> ())?
}

class MoreViewController: UIViewController {
    
    //MARK: UI Componenets
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(MoreLogoCell.self)
            view.register(MoreItemCell.self)
            view.registerHeader(MoreSectionHeaderView.self)
            view.alwaysBounceVertical = true
    }
    fileprivate var properties = [(sectionName: String, items: Array<MoreItem>)]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.properties = [
            ("Player", [
                MoreItem(name: "Remove All Bookmarks") { [weak self] in
                    self?.removeAllBookmarks()
                }]),
            ("Review", [
                MoreItem(name: "Feeback") { [weak self] in
                    self?.openFeedbackMail()
                },
                MoreItem(name: "BugReport") { [weak self] in
                    self?.openBugReport()
                },
                MoreItem(name: "Write a App Review") {
                    guard let url = URL(string: "itms-apps://itunes.apple.com/app/id1269932365") else { return }
                    UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
                }]),
            ("ETC", [
                MoreItem(name: "OpenSource") {
                    let carte = CarteViewController()
                    Navigator.push(carte)
                }])]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "More"
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.view)
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    public func updateContentInset() {
        guard let navigationBarHeight = self.navigationController?.navigationBar.frame.height else { return }
        let topOffset = navigationBarHeight + UIApplication.shared.statusBarFrame.height
        if PlayerView.isVisible() {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, PlayerView.height(), 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, PlayerView.height(), 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(topOffset, 0, 0, 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, PlayerView.height(), 0)
        }
    }
    
    func openFeedbackMail() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("Feedback")
        mc.setToRecipients(["listennrepeat@gmail.com"])
        Navigator.present(mc)
    }
    
    func openBugReport() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("BugReport")
        mc.setToRecipients(["listennrepeat@gmail.com"])
        Navigator.present(mc)
    }
    
    func removeAllBookmarks() {
        let alert = UIAlertController(title: "Remove Bookmarks", message: "Do you want to remove all bookmarks?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
            Player.shared.removeAllBookmarks()
        })
        Navigator.present(alert)
    }
}

extension MoreViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 + self.properties.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return self.properties[section - 1].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0) {
            let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as MoreLogoCell
            return cell
        }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as MoreItemCell
        cell.propertyName = self.properties[indexPath.section - 1].items[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.deqeueResuableHeader(forIndexPath: indexPath) as MoreSectionHeaderView
        if (indexPath.section > 0) {
            view.headerName = self.properties[indexPath.section - 1].sectionName
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.section == 0) {
            return CGSize(width: UIScreen.mainWidth, height: MoreLogoCell.height())
        }
        return CGSize(width: UIScreen.mainWidth, height: MoreItemCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if (section == 0) {
            return CGSize.zero
        }
        return CGSize(width: collectionView.bounds.width, height: MoreSectionHeaderView.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0) {
            return
        }
        if let action = self.properties[indexPath.section - 1].items[indexPath.row].action {
            action()
        }
    }
}

extension MoreViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail sent failure: \(String(describing: error?.localizedDescription))")
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
