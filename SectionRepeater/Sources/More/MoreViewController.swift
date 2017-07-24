//
//  MoreViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MessageUI
import Carte
import URLNavigator

enum MorePropertyType: Int {
    case feedback
    case bugReport
    case removeAllBookmarks
    case appReview
    case openSource
    case numberOfProperty
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
            view.alwaysBounceVertical = true
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
    
    func openFeedbackMail() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("Feedback")
        mc.setMessageBody("If you dissatisfy with this application, please tell us about that.", isHTML: false)
        mc.setToRecipients(["kys911015@gmail.com"])
        self.present(mc, animated: true, completion: nil)
    }
    
    func openBugReport() {
        let mc = MFMailComposeViewController()
        mc.mailComposeDelegate = self
        mc.setSubject("BugReport")
        mc.setMessageBody("If you want us to fix bug, please tell us about that", isHTML: false)
        mc.setToRecipients(["kys911015@gmail.com"])
        self.present(mc, animated: true, completion: nil)
    }

    func removeAllBookmarks() {
        let alert = UIAlertController(title: "Remove Bookmarks", message: "do you want to remove all bookmarks?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
            Player.shared.removeAllBookmarks()
        })
        self.present(alert, animated: true, completion: nil)
    }
}

extension MoreViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        }
        return MorePropertyType.numberOfProperty.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0) {
            let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as MoreLogoCell
            return cell
        }
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as MoreItemCell
        guard let propertyType = MorePropertyType(rawValue: indexPath.row) else { return UICollectionViewCell() }
        switch propertyType {
        case .feedback:
            cell.propertyName = "Feeback"
            break
        case .bugReport:
            cell.propertyName = "BugReport"
            break
        case .removeAllBookmarks:
            cell.propertyName = "Remove All Bookmarks"
            break
        case .appReview:
            cell.propertyName = "Write a App Review"
            break
        case .openSource:
            cell.propertyName = "OpenSource"
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (indexPath.section == 0) {
            return CGSize(width: UIScreen.mainWidth, height: MoreLogoCell.height())
        }
        return CGSize(width: UIScreen.mainWidth, height: MoreItemCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let propertyType = MorePropertyType(rawValue: indexPath.row) else { return }
        switch propertyType {
        case .feedback:
            self.openFeedbackMail()
            break
        case .bugReport:
            self.openBugReport()
            break
        case .removeAllBookmarks:
            self.removeAllBookmarks()
            break
        case .appReview:
            guard let url = URL(string: "itms-apps://itunes.com/apps/SectionRepeater") else { return }
            UIApplication.shared.open(url, options: [String: Any](), completionHandler: nil)
            break
        case .openSource:
            let carte = CarteViewController()
            Navigator.push(carte)
            break
        default:
            break
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
