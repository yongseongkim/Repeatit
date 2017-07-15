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
        self.title = "Songs in Album"
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(self.collectionView)
        self.updateConstraints()
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
        cell.indexLabel.text = String(indexPath.row)
        cell.nameLabel.text = self.collections[indexPath.row].representativeItem?.title
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
        if let item = self.collection?.representativeItem {
            view.coverImageView.image = item.artwork?.image(at: UIScreen.mainSize)
            view.nameLabel.text = item.albumTitle
            view.artistNameLabel.text = item.artist
            view.numberOfSongsLabel.text = String(format: "%d songs", collectionView.numberOfItems(inSection: 0))
        } else {
            view.coverImageView.image = nil
            view.nameLabel.text = "album Title"
            view.artistNameLabel.text = "artist Name"
            view.numberOfSongsLabel.text = "0 songs"

        }
        return view
    }
}
