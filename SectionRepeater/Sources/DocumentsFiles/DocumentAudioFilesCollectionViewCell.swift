//
//  DocumentAudioFilesCollectionViewCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol DocumentAudioFilesCollectionViewCellDelegate {
    func didTappedDelete(item: FileDisplayItem?)
}

class DocumentAudioFilesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    public var delegate: DocumentAudioFilesCollectionViewCellDelegate?
    
    public var item: FileDisplayItem? {
        didSet {
            if let item = item {
                if (item.isParentDirectory) {
                    
                }
                imageView.image = nil
                nameLabel.text = item.name
            } else {
                imageView.image = nil
                nameLabel.text = ""
            }
        }
    }
    
    class func height() -> CGFloat {
        return 50
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.delegate?.didTappedDelete(item: self.item)
    }
}
