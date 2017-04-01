//
//  AudioBookmarkCollectionViewCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol AudioBookmarkCollectionViewCellDelegate {
    func didTapDeleteButton(cell: AudioBookmarkCollectionViewCell)
}

class AudioBookmarkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var bookmarkTimeLabel: UILabel!
    
    public var delegate: AudioBookmarkCollectionViewCellDelegate?
    public var index: Int?
    public var time: Double?
    
    class func height() -> CGFloat {
        return 50
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.indexLabel.text = "0"
        self.bookmarkTimeLabel.text = "wrong time."
    }
    
    public func load() {
        if let index = self.index, let time = self.time {
            self.indexLabel.text = String(format: "%d", index)
            self.bookmarkTimeLabel.text = String(format: "%.1f", time)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.delegate?.didTapDeleteButton(cell: self)
    }

}
