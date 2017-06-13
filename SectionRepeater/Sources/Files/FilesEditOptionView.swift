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
    func optionAddButtonTapped()
    func optionEditButtonTapped()
    func optionMoveButtonTapped()
    func optionDeleteButtonTapped()
    func optionDoneButtonTapped()
}

class FilesEditOptionView: UIView {

    //MARK: UI Componenets
    fileprivate let addButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_common_plus_44pt"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    fileprivate let editButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_edit_file_44pt"), for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    fileprivate let moveButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_move_file_44pt"), for: .normal)
        button.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
    }
    fileprivate let deleteButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_delete_file_44pt"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    fileprivate let doneButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "common_check_44pt"), for: .normal)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }
    
    //MARK: Properties
    public var delegate: FilesEditOptionViewDelegate?
    public var selectedIndexPaths: [IndexPath]? {
        didSet {
            self.updateStatus()
        }
    }
    public var currentURL: URL?
    
    class func height() -> CGFloat {
        return 64
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.backgroundColor = UIColor.white
        self.addSubview(addButton)
        self.addSubview(editButton)
        self.addSubview(moveButton)
        self.addSubview(deleteButton)
        self.addSubview(doneButton)
        
        let borderView = UIView()
        borderView.backgroundColor = UIColor.gray145
        self.addSubview(borderView)
        borderView.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(UIScreen.scaleWidth)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
        }
        editButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(addButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(addButton.snp.width)
        }
        moveButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(editButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(editButton.snp.width)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.left.equalTo(moveButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(moveButton.snp.width)
        }
        doneButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.right.equalTo(self)
            make.left.equalTo(deleteButton.snp.right)
            make.bottom.equalTo(self)
            make.width.equalTo(deleteButton.snp.width)
        }
        self.updateStatus()
    }
    
    func updateStatus() {
        if let selectedPaths = self.selectedIndexPaths {
            self.editButton.isEnabled = (selectedPaths.count == 1)
            self.moveButton.isEnabled = (selectedPaths.count > 0)
            self.deleteButton.isEnabled = (selectedPaths.count > 0)
        } else {
            self.editButton.isEnabled = false
            self.moveButton.isEnabled = false
            self.deleteButton.isEnabled = false
        }
    }

    func addButtonTapped() {
        self.delegate?.optionAddButtonTapped()
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
