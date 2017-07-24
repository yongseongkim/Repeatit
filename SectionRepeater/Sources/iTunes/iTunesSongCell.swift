//
//  iTunesSongCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 7..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesSongCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 56
    }
    
    //MARK: UI Components
    fileprivate let titleLabel = UILabel().then { (label) in
        label.font = label.font.withSize(14)
        label.textColor = UIColor.black
    }
    fileprivate let artistLabel = UILabel().then { (label) in
        label.font = label.font.withSize(11)
        label.textColor = UIColor.gray145
    }
    fileprivate let albumCoverImageView = UIImageView().then { (view) in
        view.layer.borderColor = UIColor.gray220.cgColor
        view.layer.borderWidth = UIScreen.scaleWidth
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    var item: MPMediaItem? {
        didSet {
            if let item = item {
                self.titleLabel.text = item.title
                self.artistLabel.text = item.artist
                self.albumCoverImageView.image = item.artwork?.image(at: albumCoverImageView.frame.size)
            } else {
                self.titleLabel.text = ""
                self.artistLabel.text = ""
                self.albumCoverImageView.image = nil
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.albumCoverImageView)
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(44)
        }
        self.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.addSubview(self.artistLabel)
        self.artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(44)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
}
