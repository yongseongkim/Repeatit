//
//  BookmarkCollectionViewCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol BookmarkCollectionViewCellDelegate {
    func didTapDeleteButton(cell: BookmarkCollectionViewCell)
}

class BookmarkCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var bookmarkTimeLabel: UILabel!
    
    public var delegate: BookmarkCollectionViewCellDelegate?
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
            let minutes = Int(abs(time/60))
            let seconds = Int(abs(time.truncatingRemainder(dividingBy: 60)))
            self.indexLabel.text = String(format: "%d", index)
            self.bookmarkTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.delegate?.didTapDeleteButton(cell: self)
    }

}
