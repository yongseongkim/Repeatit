//
//  iTunesMenuCell.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class iTunesMenuCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 52
    }
    
    //MARK: UI Components
    fileprivate let nameLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    fileprivate let arrowView = UIImageView(image: UIImage(named: "arrow_44pt"))
    //MARK: Properties
    public var menuName: String? {
        didSet {
            self.nameLabel.text = menuName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.arrowView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.borderView)
        
        self.arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.width.height.equalTo(44)
            make.centerY.equalTo(self)
        }
        self.nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self.arrowView.snp.left).offset(-10)
            make.centerY.equalTo(self)
        }
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(44)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
