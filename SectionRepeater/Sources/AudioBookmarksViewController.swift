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

    fileprivate var bookmarkObject: BookmarkObject?
    public var targetPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadBookmark()
    }
    
    func loadBookmark() {
        let realm = try! Realm()
        guard let targetPath = self.targetPath else { return }
        self.bookmarkObject = realm.objects(BookmarkObject.self).filter(String.init(format: "path = '%@'", targetPath)).first
        self.collectionView.reloadData()
    }
    
    @IBAction func closeButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension AudioBookmarksViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfBookmarkTimes = self.bookmarkObject?.times.count {
            return numberOfBookmarkTimes
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as AudioBookmarkCollectionViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.time = self.bookmarkObject?.times[indexPath.row].value
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
        guard let deleteTime = cell.time else { return }
        if let time = self.bookmarkObject?.times.filter({ (dObj) -> Bool in return dObj.value == deleteTime }).first {
            if let index = self.bookmarkObject?.times.index(of: time) {
                let realm = try! Realm()
                try! realm.write {
                    self.bookmarkObject?.times.remove(objectAtIndex: index)
                }
            }
        }
        self.collectionView.reloadData()
    }
}
