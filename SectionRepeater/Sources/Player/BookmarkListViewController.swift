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
    @IBOutlet weak var bottomBorderViewHeightConstraint: NSLayoutConstraint!
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark)).then { (effectView) in
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    //MARK: Properties
    fileprivate var bookmarkTimes: [Double]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.blurEffectView.frame = self.view.bounds
        self.view.insertSubview(blurEffectView, belowSubview: self.contentView)
        self.borderViewHeightConstraint.constant = UIScreen.scaleWidth
        self.bottomBorderViewHeightConstraint.constant = UIScreen.scaleWidth
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handleBookmarkUpdatedNotification), name: Notification.Name.playerBookmakrUpdated, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBookmark()
        self.blurEffectView.alpha = 0
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.blurEffectView.alpha = 1.0
        }
        let scaleAnim = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnim.values = [0.9, 1.05, 0.98, 1]
        scaleAnim.duration = 0.3
        self.contentView.layer.add(scaleAnim, forKey: nil)
    }
    
    func loadBookmark() {
        self.bookmarkTimes = Player.shared.bookmarkTimes
        self.collectionView.reloadData()
    }
    
    func handleBookmarkUpdatedNotification() {
        self.loadBookmark()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func removeAllBookmarksButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Remove Bookmarks", message: "Do you want to remove playing item's bookmarks?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default) { (action) in
            Player.shared.removeCurrentPlayingItemAllBookmarks()
        })
        self.present(alert, animated: true, completion: nil)
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
        cell.hideBorderView = (indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1)
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
