//
//  BookmarkCollectionViewCell.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 4. 1..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol BookmarkCollectionViewCellDelegate {
    func didTapDeleteButton(cell: BookmarkCollectionViewCell)
}

class BookmarkCollectionViewCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 50
    }
    
    //MARK: UI Components
    fileprivate let indexLabel = UILabel().then { (label) in
        label.font = label.font.withSize(13)
        label.textAlignment = .center
        label.textColor = UIColor.gray145
    }
    fileprivate let timeLabel = UILabel().then { (label) in
        label.font = label.font.withSize(15)
        label.textColor = UIColor.black
    }
    fileprivate let deleteButton = UIButton().then { (button) in
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "btn_delete_file_44pt"), for: .normal)
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    public var delegate: BookmarkCollectionViewCellDelegate?
    public var index: Int = 0 {
        didSet {
            self.indexLabel.text = String(format: "%d", index)
        }
    }
    public var time: Double? {
        didSet {
            guard let time = time else { return }
            let minutes = Int(abs(time/60))
            let seconds = Int(abs(time.truncatingRemainder(dividingBy: 60)))
            self.timeLabel.text = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    public var hideBorderView = false {
        didSet {
            self.borderView.isHidden = hideBorderView
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.indexLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.deleteButton)
        self.addSubview(self.borderView)
        
        self.indexLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.width.equalTo(30)
            make.centerY.equalTo(self)
        }
        self.timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(50)
            make.right.equalTo(self).offset(-50)
            make.centerY.equalTo(self)
        }
        self.deleteButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(36)
        }
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(44)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
        self.deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func deleteButtonTapped() {
        self.delegate?.didTapDeleteButton(cell: self)
    }
}
