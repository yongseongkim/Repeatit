//
//  FileEditOptionView.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 11..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol FileEditOptionViewDelegate {
    func optionAddButtonTapped()
    func optionEditButtonTapped()
    func optionMoveButtonTapped()
    func optionDeleteButtonTapped()
}

class FileEditOptionView : UIView {
    
    static let buttonHeight = 44
    
    class func height() -> CGFloat {
        return UIConstants.TabBarHeight
    }
    
    //MARK: UI Components
    fileprivate let addButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_add_folder_44pt"), for: .normal)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    fileprivate let editButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_edit_file_44pt"), for: .normal)
        button.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    fileprivate let moveButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_move_files_44pt"), for: .normal)
        button.addTarget(self, action: #selector(moveButtonTapped), for: .touchUpInside)
    }
    fileprivate let deleteButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_delete_file_44pt"), for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    //MARK: Properties
    public var delegate: FileEditOptionViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.backgroundColor = UIColor.gray243.withAlphaComponent(0.5)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.addSubview(addButton)
        self.addSubview(editButton)
        self.addSubview(moveButton)
        self.addSubview(deleteButton)
        
        addButton.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
            make.height.equalTo(FileEditOptionView.buttonHeight)
        }
        editButton.snp.makeConstraints { (make) in
            make.left.equalTo(addButton.snp.right)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(addButton.snp.width)
            make.height.equalTo(FileEditOptionView.buttonHeight)
        }
        moveButton.snp.makeConstraints { (make) in
            make.left.equalTo(editButton.snp.right)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(editButton.snp.width)
            make.height.equalTo(FileEditOptionView.buttonHeight)
        }
        deleteButton.snp.makeConstraints { (make) in
            make.left.equalTo(moveButton.snp.right)
            make.right.equalTo(self)
            make.centerY.equalTo(self.snp.centerY)
            make.width.equalTo(moveButton.snp.width)
            make.height.equalTo(FileEditOptionView.buttonHeight)
        }
        self.updateStatus()
    }
    
    func updateStatus() {
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
}
