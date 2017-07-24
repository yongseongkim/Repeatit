//
//  BookmarkListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RealmSwift

class BookmarkListViewController: UIViewController {

    //MARK: UI Components
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(BookmarkCollectionViewCell.self)
            collectionView.alwaysBounceVertical = true
        }
    }
    @IBOutlet weak var borderViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    fileprivate var bookmarkTimes: [Double]?
    public var targetPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(blurEffectView, belowSubview: self.contentView)
        self.borderViewHeightConstraint.constant = UIScreen.scaleWidth
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBookmark()
    }
    
    func loadBookmark() {
        self.bookmarkTimes = Player.shared.bookmarkTimes
        self.collectionView.reloadData()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

}

extension BookmarkListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfBookmarkTimes = self.bookmarkTimes?.count {
            return numberOfBookmarkTimes
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as BookmarkCollectionViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.time = self.bookmarkTimes?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let time = self.bookmarkTimes?[indexPath.row] {
            Player.shared.move(to: time)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: BookmarkCollectionViewCell.height())
    }
}

extension BookmarkListViewController: BookmarkCollectionViewCellDelegate {
    func didTapDeleteButton(cell: BookmarkCollectionViewCell) {
        guard let removedTime = cell.time else { return }
        Player.shared.removeBookmark(at: removedTime)
        self.loadBookmark()
    }
}
