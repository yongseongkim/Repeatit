//
//  MoreLogoCell.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 22..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class MoreLogoCell: UICollectionViewCell {
    
    let logoView = UIView()
    let logoImageView = UIImageView(image: UIImage(named: "more_logo_100pt"))
    let logoLabel = UILabel(frame: .zero).then { (label) in
        label.text = "SectionRepeater"
    }
    
    class func height() -> CGFloat {
        return 150
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.logoView.addSubview(self.logoImageView)
        self.logoView.addSubview(self.logoLabel)
        self.addSubview(self.logoView)
        
        self.logoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(self.logoView)
            make.centerX.equalTo(self.logoView)
            make.width.height.equalTo(100)
        }
        self.logoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.logoImageView.snp.bottom)
            make.centerX.equalTo(self.logoView)
            make.height.equalTo(21)
        }
        self.logoView.snp.makeConstraints { (make) in
            make.centerX.centerY.equalTo(self)
            make.left.right.equalTo(self)
            make.height.equalTo(121)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
