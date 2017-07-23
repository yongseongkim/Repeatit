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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var seperateViewHeightConstraint: NSLayoutConstraint!
    
    var collection: MPMediaItemCollection? {
        didSet {
            guard let item = collection?.representativeItem else {
                self.titleLabel.text = ""
                self.artistNameLabel.text = ""
                self.coverImageView.image = nil
                return
            }
            self.titleLabel.text = item.albumTitle
            self.artistNameLabel.text = item.artist
            self.coverImageView.image = item.artwork?.image(at: coverImageView.frame.size)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.coverImageView.layer.borderColor = UIColor.gray220.cgColor
        self.coverImageView.layer.borderWidth = UIScreen.scaleWidth
        self.seperateViewHeightConstraint.constant = UIScreen.scaleWidth
    }

}
