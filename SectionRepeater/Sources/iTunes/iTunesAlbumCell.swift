//
//  iTunesAlbumCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesAlbumCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 100
    }

    //MARK: UI Components
    fileprivate let albumCoverImageView = UIImageView().then { (view) in
        view.layer.borderColor = UIColor.gray220.cgColor
        view.layer.borderWidth = UIScreen.scaleWidth
    }
    fileprivate let textContainerView = UIView().then { (view) in
        view.backgroundColor = UIColor.clear
    }
    fileprivate let titleLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
        label.textAlignment = .center
    }
    fileprivate let artistLabel = UILabel().then { (label) in
        label.font = label.font.withSize(14)
        label.textColor = UIColor.gray145
        label.textAlignment = .center
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }

    //MARK: Properties
    var collection: MPMediaItemCollection? {
        didSet {
            guard let item = collection?.representativeItem else {
                self.titleLabel.text = ""
                self.artistLabel.text = ""
                self.albumCoverImageView.image = nil
                return
            }
            self.titleLabel.text = item.albumTitle
            self.artistLabel.text = item.artist
            self.albumCoverImageView.image = item.artwork?.image(at: albumCoverImageView.frame.size)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.albumCoverImageView)
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(80)
        }
        self.textContainerView.addSubview(self.titleLabel)
        self.textContainerView.addSubview(self.artistLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.textContainerView)
            make.height.equalTo(21)
        }
        self.artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(self.textContainerView)
            make.height.equalTo(17)
        }
        self.addSubview(self.textContainerView)
        self.textContainerView.snp.makeConstraints { (make) in
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        self.textContainerView.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        self.textContainerView.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(80)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }

}
