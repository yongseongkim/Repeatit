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
    fileprivate var itunesListViewController: iTunesListViewController?
    fileprivate var itunesSongListViewController: iTunesSongListViewController?
    fileprivate var playerView: AudioPlayerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = UIColor.black
        let fileListViewController = FileListViewController()
        fileListViewController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(named: "empty_common_folder_28pt"), selectedImage: UIImage(named: "fill_common_folder_28pt"))
        let itunesListViewController = iTunesListViewController()
        itunesListViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(named: "empty_music_note_28pt"), selectedImage: UIImage(named: "fill_music_note_28pt"))
        
        self.fileListViewController = fileListViewController
        self.itunesListViewController = itunesListViewController
        
        let viewControllers = [UINavigationController(rootViewController: fileListViewController), itunesListViewController]
        self.setViewControllers(viewControllers, animated: false)
    }
}
