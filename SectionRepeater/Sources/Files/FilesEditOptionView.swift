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
    func optionEditButtonTapped()
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
        self.backgroundColor = UIColor.greenery
        
        let editButton = UIButton()
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(UIColor.black, for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        self.addSubview(editButton)
        
        let moveButton = UIButton()
        moveButton.setTitle("Move", for: .normal)
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
        
        
        editButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
        }
        moveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(editButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(editButton.snp.width)
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
            make.width.equalTo(deleteButton.snp.width)
        }
    }
    
    func editButtonTapped() {
        self.delegate?.optionEditButtonTapped()
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
