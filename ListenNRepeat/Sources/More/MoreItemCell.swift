//
//  MoreItemCell.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 7. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class MoreItemCell: UICollectionViewCell {
    
    class func height() -> CGFloat {
        return 44
    }
    
    //MARK: UI Components
    fileprivate let propertyLabel = UILabel().then { (label) in
        label.font = label.font.withSize(17)
        label.textColor = UIColor.black
    }
    fileprivate let arrowView = UIImageView(image: UIImage(named: "arrow_44pt"))
    
    //MARK: Properties
    public var propertyName: String? {
        didSet {
            self.propertyLabel.text = propertyName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.arrowView)
        self.addSubview(self.propertyLabel)
        
        self.arrowView.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-10)
            make.width.height.equalTo(44)
            make.centerY.equalTo(self)
        }
        self.propertyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self.arrowView.snp.left).offset(-10)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
