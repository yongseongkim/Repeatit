//
//  RootViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit

class RootViewController: UITabBarController {
    
    fileprivate var fileListViewController: FileListViewController?
    fileprivate var ituensSongListViewController: iTunesSongListViewController?
    fileprivate var playerView: AudioPlayerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let fileListViewController = FileListViewController()
        fileListViewController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(), tag: 0)
        let ituensSongListViewController = iTunesSongListViewController()
        ituensSongListViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(), tag: 0)
        
        self.fileListViewController = fileListViewController
        self.ituensSongListViewController = ituensSongListViewController
        let viewControllers = [UINavigationController(rootViewController: fileListViewController), UINavigationController(rootViewController: ituensSongListViewController)]
        self.setViewControllers(viewControllers, animated: false)
    }
    

}
