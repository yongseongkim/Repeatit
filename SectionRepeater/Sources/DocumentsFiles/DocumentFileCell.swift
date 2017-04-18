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
    public var editing: Bool = false
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
    override var isSelected: Bool {
        didSet {
            if (isSelected && editing) {
                self.coverImageView.isHidden = true
                self.selectedImageView.isHidden = false
            } else {
                self.coverImageView.isHidden = false
                self.selectedImageView.isHidden = true
            }
        }
    }
    
    class func height() -> CGFloat {
        return 50
    }
    
}
