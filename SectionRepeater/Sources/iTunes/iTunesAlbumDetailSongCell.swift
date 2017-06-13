//
//  iTunesAlbumDetailSongCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class iTunesAlbumDetailSongCell: UICollectionViewCell {
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var borderViewHeightConstraint: NSLayoutConstraint!
    
    class func height() -> CGFloat {
        return 50
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.borderViewHeightConstraint.constant = UIScreen.scaleWidth
    }
}
