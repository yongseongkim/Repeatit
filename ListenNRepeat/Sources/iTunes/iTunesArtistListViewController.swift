//
//  iTunesArtistListViewController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import MediaPlayer
import URLNavigator

class iTunesArtistListViewController: UIViewController {
    fileprivate let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
        ).then { (view) in
            view.backgroundColor = UIColor.white
            view.register(iTunesArtistCell.self)
            view.alwaysBounceVertical = true
    }
    
    //MARK: Properties
    fileprivate var collections = [MPMediaItemCollection]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        self.title = "Artists"
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.collectionView)
        
        self.updateConstraints()
        self.updateContentInset()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let collections = MPMediaQuery.artists().collections {
            self.collections = collections
        }
    }
    
    func updateConstraints() {
        self.collectionView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.view)
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
    
    func enterForeground() {
        self.collectionView.reloadData()
    }
}

extension iTunesArtistListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.deqeueResuableCell(forIndexPath: indexPath) as iTunesArtistCell
        cell.collection = self.collections[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumListViewController = iTunesAlbumListViewController()
        albumListViewController.collection = self.collections[indexPath.row]
        Navigator.push(albumListViewController)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.mainWidth, height: iTunesArtistCell.height())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
