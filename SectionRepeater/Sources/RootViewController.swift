//
//  RootViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class RootViewController: UITabBarController {
    
    fileprivate var documentsViewController: DocumentAudioFilesViewController?
    fileprivate var iTunesViewController: iTuensSongsViewController?
    fileprivate var playerView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsViewController = DocumentAudioFilesViewController(nibName: DocumentAudioFilesViewController.className(), bundle: nil)
        documentsViewController.tabBarItem = UITabBarItem(title: "documents", image: UIImage(), tag: 0)
        let iTunesViewController = iTuensSongsViewController(nibName: iTuensSongsViewController.className(), bundle: nil)
        iTunesViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(), tag: 0)
        
        self.documentsViewController = documentsViewController
        self.iTunesViewController = iTunesViewController
        let viewControllers = [UINavigationController(rootViewController: documentsViewController), UINavigationController(rootViewController: iTunesViewController)]
        self.setViewControllers(viewControllers, animated: false)
    }
}
