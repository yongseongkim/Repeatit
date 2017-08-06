//
//  FileListNavigationController.swift
//  ListenNRepeat
//
//  Created by nelson on 2017. 7. 15..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class FileListNavigationController : UINavigationController {

    init() {
        super.init(nibName: nil, bundle: nil)
        self.setViewControllers([FileListViewController()], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateContentInset() {
        for vc in self.viewControllers {
            if let fileListViewController = vc as? FileListViewController {
                fileListViewController.updateContentInset()
            }
        }
    }

}
