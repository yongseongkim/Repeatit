//
//  iTunesPlaylistItemCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesPlaylistItemCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 50
    }
    
    let nameLabel = UILabel()
    let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    var collection: MPMediaItemCollection? {
        didSet {
            if let playlist = collection as? MPMediaPlaylist {
                self.nameLabel.text = playlist.name
            } else {
                self.nameLabel.text = ""
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(45)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
    
}
