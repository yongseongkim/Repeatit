//
//  iTunesAlbumDetailHeaderView.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 13..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class iTunesAlbumDetailHeaderView: UICollectionReusableView {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var numberOfSongsLabel: UILabel!
    
    class func height() -> CGFloat {
        return 140
    }
}
