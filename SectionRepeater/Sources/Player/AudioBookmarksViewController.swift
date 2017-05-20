//
//  AudioBookmarksViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RealmSwift

class AudioBookmarksViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(AudioBookmarkCollectionViewCell.self)
        }
    }

    fileprivate let player = Dependencies.sharedInstance().resolve(serviceType: Player.self)
    fileprivate var bookmarkTimes: [Double]?
    public var targetPath: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBookmark()
    }
    
    func loadBookmark() {
        self.bookmarkTimes = self.player?.bookmarks
        self.collectionView.reloadData()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AudioBookmarksViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfBookmarkTimes = self.bookmarkTimes?.count {
            return numberOfBookmarkTimes
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as AudioBookmarkCollectionViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.time = self.bookmarkTimes?[indexPath.row]
        cell.load()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: play the time
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: AudioBookmarkCollectionViewCell.height())
    }
}

extension AudioBookmarksViewController: AudioBookmarkCollectionViewCellDelegate {
    func didTapDeleteButton(cell: AudioBookmarkCollectionViewCell) {
        guard let removedTime = cell.time else { return }
        self.player?.removeBookmark(at: removedTime)
        self.loadBookmark()
    }
}
