//
//  iTunesSongCell.swift
//  ListenNRepeat
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
        label.font = label.font.withSize(12)
        label.textColor = UIColor.gray145
    }
    fileprivate let albumCoverImageView = UIImageView().then { (view) in
        view.layer.borderColor = UIColor.gray220.cgColor
        view.layer.borderWidth = UIScreen.scaleWidth
        view.contentMode = .scaleAspectFit
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
                self.albumCoverImageView.image = item.artwork?.image(at: albumCoverImageView.frame.size) ?? UIImage(named: "music_note_empty_44pt")
            } else {
                self.titleLabel.text = ""
                self.artistLabel.text = ""
                self.albumCoverImageView.image = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.albumCoverImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.artistLabel)
        self.addSubview(self.borderView)
        
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(44)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.artistLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
        }
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(44)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
