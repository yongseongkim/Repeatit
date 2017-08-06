//
//  iTunesPlaylistItemCell.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesPlaylistItemCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 44
    }
    
    //MARK: UI Components
    fileprivate  let nameLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    var collection: MPMediaItemCollection? {
        didSet {
            if let playlist = collection as? MPMediaPlaylist {
                self.nameLabel.text = playlist.name
            } else {
                self.nameLabel.text = ""
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.nameLabel)
        self.addSubview(self.borderView)
        
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
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
