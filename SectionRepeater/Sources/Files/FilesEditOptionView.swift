//
//  FilesEditOptionView.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 4. 30..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import SnapKit

protocol FilesEditOptionViewDelegate {
    func optionMoveButtonTapped()
    func optionDeleteButtonTapped()
    func optionDoneButtonTapped()
}

class FilesEditOptionView: UIView {

    public var delegate: FilesEditOptionViewDelegate?
    
    class func height() -> CGFloat {
        return 44
    }
    
    class func edgeInset() -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 10, 5, 10)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.backgroundColor = UIColor.greenery()
        let moveButton = UIButton()
        moveButton.setTitle("move", for: .normal)
        moveButton.setTitleColor(UIColor.black, for: .normal)
        moveButton.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
        self.addSubview(moveButton)
        
        let deleteButton = UIButton()
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor.black, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        self.addSubview(deleteButton)
        
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.black, for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        self.addSubview(doneButton)
        
        moveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(moveButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(moveButton.snp.width)
        }
        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.left.equalTo(deleteButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(moveButton.snp.width)
        }
    }
    
    func moveButtonTapped() {
        self.delegate?.optionMoveButtonTapped()
    }
    
    func deleteButtonTapped() {
        self.delegate?.optionDeleteButtonTapped()
    }
    
    func doneButtonTapped() {
        self.delegate?.optionDoneButtonTapped()
    }
}
