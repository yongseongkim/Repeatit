//
//  iTunesAlbumDetailHeaderView.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesAlbumDetailHeaderView: UICollectionReusableView {
    
    class func height() -> CGFloat {
        return 140
    }
    
    //MARK: UI Components
    fileprivate let albumCoverImageView = UIImageView().then { (view) in
        view.layer.borderColor = UIColor.gray220.cgColor
        view.layer.borderWidth = UIScreen.scaleWidth
    }
    fileprivate let albumTitleLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
        label.textAlignment = .left
    }
    fileprivate let artistLabel = UILabel().then { (label) in
        label.font = label.font.withSize(14)
        label.textColor = UIColor.gray145
        label.textAlignment = .left
    }
    fileprivate let numberOfSongsLabel = UILabel().then { (label) in
        label.font = label.font.withSize(15)
        label.textColor = UIColor.black
        label.textAlignment = .right
    }
    
    //MARK: Properties
    public var collection: MPMediaItemCollection? {
        didSet {
            if let item = self.collection?.representativeItem {
                self.albumCoverImageView.image = item.artwork?.image(at: UIScreen.mainSize)
                self.albumTitleLabel.text = item.albumTitle
                self.artistLabel.text = item.artist
            } else {
                self.albumCoverImageView.image = nil
                self.albumTitleLabel.text = "Album Title"
                self.artistLabel.text = "Artist Name"
            }
        }
    }
    public var numberOfSongs: Int = 0 {
        didSet {
            self.numberOfSongsLabel.text = String(format: "%d tracks", numberOfSongs)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.albumCoverImageView)
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(120)
        }
        self.addSubview(self.albumTitleLabel)
        self.albumTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.albumCoverImageView).offset(10)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.albumTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.addSubview(self.numberOfSongsLabel)
        self.numberOfSongsLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.bottom.equalTo(self.albumCoverImageView)
            make.right.equalTo(self).offset(-20)
        }
    }

}
