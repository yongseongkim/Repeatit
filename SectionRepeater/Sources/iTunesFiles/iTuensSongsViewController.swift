//
//  iTuensSongsViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTuensSongsViewController: UIViewController {
    
    var items: [MPMediaItem]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(iTunesSongCollectionViewCell.self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeViewController))
        self.navigationItem.rightBarButtonItem = closeButton
        self.items = MPMediaQuery.songs().items
    }
    
    func closeViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension iTuensSongsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let items = self.items {
            return items.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesSongCollectionViewCell
        cell.item = items?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: iTunesSongCollectionViewCell.height())
    }
}

extension iTuensSongsViewController: UICollectionViewDelegate {
    
}
