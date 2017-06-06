//
//  DocumentFileCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import URLNavigator

class FileCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var separateViewHeightConstraint: NSLayoutConstraint!
    public var editing: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separateViewHeightConstraint.constant = UIScreen.scaleWidth
    }
    
    public var file: File? {
        didSet {
            if let file = file {
                if file.isDirectory {
                    // TODO: set directory image
                    coverImageView.image = nil
                }
                if let image = file.audioInformation?.artwork {
                    coverImageView.image = image
                } else {
                    // TODO: set default image
                    coverImageView.image = nil
                }
                
                nameLabel.text = file.name
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
