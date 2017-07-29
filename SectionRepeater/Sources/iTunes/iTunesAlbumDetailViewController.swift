//
//  iTunesAlbumDetailViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer
import URLNavigator

class iTunesAlbumDetailViewController: UIViewController {
    
    //MARK: UI Components
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then { (view) in
        view.backgroundColor = UIColor.clear
        view.register(iTunesAlbumDetailSongCell.self)
        view.registerHeader(iTunesAlbumDetailHeaderView.self)
        view.alwaysBounceVertical = true
    }
    //MARK: Properties
    fileprivate var collections = [MPMediaItemCollection]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    public var collection: MPMediaItemCollection? {
        didSet {
            self.loadAlbumsSongs()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tracks(Album)"
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.collectionView)
        
        self.updateConstraints()
        self.updateContentInset()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAlbumsSongs()
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    public func updateContentInset() {
        if PlayerView.isVisible() {
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, PlayerView.height(), 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, PlayerView.height(), 0)
        } else {
            self.collectionView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
            self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 0, 0)
        }
    }
    
    func bind() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
    func loadAlbumsSongs() {
        guard let item = self.collection?.representativeItem else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        var predicates = Set<MPMediaPropertyPredicate>()
        if let artistName = item.artist {
            predicates.insert(MPMediaPropertyPredicate(value: artistName, forProperty: MPMediaItemPropertyArtist, comparisonType: .equalTo))
        }
        if let albumTitle = item.albumTitle {
            predicates.insert(MPMediaPropertyPredicate(value: albumTitle, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: .equalTo))
        }
        if (predicates.count == 0) {
            self.navigationController?.popViewController(animated: true)
            return
        }
        if let collections = MPMediaQuery(filterPredicates: predicates).collections {
            self.collections = collections
        }
    }
}

extension iTunesAlbumDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesAlbumDetailSongCell
        cell.index = indexPath.row
        cell.item = self.collections[indexPath.row].representativeItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do {
            let items: [MPMediaItem] = self.collections.flatMap({ (collection) -> MPMediaItem? in
                return collection.representativeItem
            })
            try Player.shared.play(items: PlayerItem.items(mediaItems: items), startAt: indexPath.row)
            let playerController = PlayerViewController(nibName: PlayerViewController.className(), bundle: nil)
            playerController.modalPresentationStyle = .custom
            Navigator.present(playerController)
        } catch let error {
            print(error)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: iTunesAlbumDetailSongCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: iTunesAlbumDetailHeaderView.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.deqeueResuableHeader(forIndexPath: indexPath) as iTunesAlbumDetailHeaderView
        view.collection = self.collection
        view.numberOfSongs = self.collections.count
        return view
    }
}
