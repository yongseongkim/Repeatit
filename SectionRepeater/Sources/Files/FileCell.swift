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
            var image: UIImage? = nil
            var filename: String = ""
            if let file = file {
                if file.isDirectory {
                    image = UIImage(named: "empty_common_folder_44pt")
                } else {
                    image = file.audioInformation?.artwork
                }
                filename = file.name
            } else {
                image = nil
            }
            self.coverImageView.image = image ?? UIImage(named: "empty_music_note_44pt")
            self.nameLabel.text = filename
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
