//
//  iTunesViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import URLNavigator

enum iTunesMenuType: Int {
    case playlist
    case artist
    case album
    case song
    case numberOfTypes
}

class iTunesViewController: UIViewController {
    
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(iTunesMenuCell.self)
            view.alwaysBounceVertical = true
    }
    
    //MARK: Properties

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iTunes"
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        
        self.updateConstraints()
        self.updateContentInset()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
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
}

extension iTunesViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return iTunesMenuType.numberOfTypes.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesMenuCell
        guard let type = iTunesMenuType(rawValue: indexPath.row) else { return UICollectionViewCell() }
        switch type {
        case .playlist:
            cell.menuName = "Playlists"
            break
        case .artist:
            cell.menuName = "Artists"
            break
        case .album:
            cell.menuName = "Albums"
            break
        case .song:
            cell.menuName = "Songs"
            break
        default:
            break
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: iTunesMenuCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let type = iTunesMenuType(rawValue: indexPath.row) else { return }
        switch type {
        case .playlist:
            Navigator.push(iTunesPlaylistViewController())
            break
        case .artist:
            Navigator.push(iTunesArtistListViewController())
            break
        case .album:
            Navigator.push(iTunesAlbumListViewController())
            break
        case .song:
            Navigator.push(iTunesSongListViewController())
            break
        default:
            break
        }
    }
}
