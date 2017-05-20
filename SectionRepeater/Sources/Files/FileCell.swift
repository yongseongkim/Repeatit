//
//  DocumentFileCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 16..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import URLNavigator

class FileCell: UICollectionViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    public var editing: Bool = false
    fileprivate var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bind()
    }
    
    public var file: File? {
        didSet {
            if let file = file {
                coverImageView.image = nil
                nameLabel.text = file.name
            } else {
                coverImageView.image = nil
                nameLabel.text = ""
            }
        }
    }
    
    func bind() {
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
