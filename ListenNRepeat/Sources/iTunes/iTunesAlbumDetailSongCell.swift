//
//  iTunesAlbumDetailSongCell.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesAlbumDetailSongCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 50
    }
    
    //MARK: UI Components
    fileprivate let indexLabel = UILabel().then { (label) in
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.textColor = UIColor.gray145
    }
    fileprivate let nameLabel = UILabel().then { (label) in
        label.font = label.font.withSize(15)
        label.textColor = UIColor.black
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    public var index: Int = 0 {
        didSet {
            self.indexLabel.text = String(format: "%d", index)
        }
    }
    public var item: MPMediaItem? {
        didSet {
            if let item = item {
                self.nameLabel.text = item.title
            } else {
                self.nameLabel.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.indexLabel)
        self.addSubview(self.nameLabel)
        self.addSubview(self.borderView)
        
        self.indexLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.width.equalTo(30)
            make.centerY.equalTo(self)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(50)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
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

