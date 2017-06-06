//
//  FileDestinationViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class FileDestinationViewController: UINavigationController {
    static let optionViewHeight:CGFloat = 44
    
    public var selectedPaths: [String]?
    
    fileprivate let optionView = UIView(frame: .zero).then { (view) in
        view.backgroundColor = UIColor.greenery
    }
    fileprivate let cancelButton = UIButton(frame: .zero).then { (button) in
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    fileprivate let movehereButton = UIButton(frame: .zero).then { (button) in
        button.setTitle("Move Here", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(movehereButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.optionView.addSubview(self.cancelButton)
        self.cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.optionView)
            make.left.equalTo(self.optionView)
            make.bottom.equalTo(self.optionView)
        }
        self.optionView.addSubview(self.movehereButton)
        self.movehereButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.optionView)
            make.left.equalTo(self.cancelButton.snp.right)
            make.bottom.equalTo(self.optionView)
            make.right.equalTo(self.optionView)
            make.width.equalTo(self.cancelButton)
        }
        self.view.addSubview(optionView)
        self.optionView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(FileDestinationViewController.optionViewHeight)
        }
    }
    
    func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func movehereButtonTapped() {
        guard let paths = self.selectedPaths else { return }
        guard let moveToURL = (self.viewControllers.last as? FileDestinationFileListViewController)?.currentURL else { return }
        for path in paths {
            do {
                if FileManager.default.fileExists(atPath: path) {
                    let url = URL(fileURLWithPath: path)
                    try FileManager.default.moveItem(atPath: path, toPath: moveToURL.appendingPathComponent(url.lastPathComponent).path)
                }
            } catch let error {
                print(error)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}
