//
//  MoreItemCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class MoreItemCell: UICollectionViewCell {
    
    let propertyLabel = UILabel()
    var propertyName: String? {
        didSet {
            self.propertyLabel.text = propertyName
        }
    }
    let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    class func height() -> CGFloat {
        return 50
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addSubview(self.propertyLabel)
        self.propertyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
        }
        self.addSubview(self.borderView)
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(45)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
    
}
