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
    
    class func height() -> CGFloat {
        return 50
    }
    
    //MARK: UI Components
    fileprivate let albumCoverImageView = UIImageView()
    fileprivate let selectedImageView = UIImageView(image: UIImage(named: "common_check_44pt"))
    fileprivate let nameLabel = UILabel().then { (label) in
        label.font = label.font.withSize(14)
        label.textColor = UIColor.black
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    public var editing: Bool = false
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
            self.albumCoverImageView.image = image ?? UIImage(named: "empty_music_note_44pt")
            self.nameLabel.text = filename
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.selectedImageView)
        self.selectedImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(36)
        }
        self.selectedImageView.isHidden = true
        self.addSubview(self.albumCoverImageView)
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(36)
        }
        self.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(32)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if (isSelected && editing) {
                self.albumCoverImageView.isHidden = true
                self.selectedImageView.isHidden = false
            } else {
                self.albumCoverImageView.isHidden = false
                self.selectedImageView.isHidden = true
            }
        }
    }
}
