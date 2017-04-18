//
//  DocumentFileCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class DocumentFileCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    public var item: FileDisplayItem? {
        didSet {
            if let item = item {
                if (item.isParentDirectory) {}
                coverImageView.image = nil
                nameLabel.text = item.name
            } else {
                coverImageView.image = nil
                nameLabel.text = ""
            }
        }
    }
    
    class func height() -> CGFloat {
        return 50
    }
}
