//
//  iTunesArtistCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class iTunesArtistCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel! 
    
    var collection: MPMediaItemCollection? {
        didSet {
            guard let item = collection?.representativeItem else {
                self.nameLabel.text = ""
                return
            }
            self.nameLabel.text = item.artist
        }
    }
    
    class func height() -> CGFloat {
        return 50
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
