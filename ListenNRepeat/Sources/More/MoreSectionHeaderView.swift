//
//  MoreSectionHeaderView.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 8. 6..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class MoreSectionHeaderView: UICollectionReusableView {
    
    class func height() -> CGFloat {
        return 56
    }
    
    //MARK: UI Components
    fileprivate let headerLabel = UILabel().then { (label) in
        label.font = label.font.withSize(14)
        label.textColor = UIColor.gray145
    }
    fileprivate let borderView = UIView().then { (view) in
        view.backgroundColor = UIColor.gray220
    }
    
    //MARK: Properties
    public var headerName: String? {
        didSet {
            self.headerLabel.text = headerName
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.headerLabel)
        self.addSubview(self.borderView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.headerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.bottom.equalTo(self).offset(-8)
        }
        self.borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(45)
            make.bottom.equalTo(self)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(UIScreen.scaleWidth)
        }
    }
}
