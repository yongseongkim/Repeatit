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

    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsViewController = DocumentAudioFilesViewController(nibName: String(describing: DocumentAudioFilesViewController.self), bundle: nil)
        documentsViewController.tabBarItem = UITabBarItem(title: "documents", image: UIImage(), tag: 0)
        let iTunesViewController = iTuensSongsViewController(nibName: String(describing: iTuensSongsViewController.self), bundle: nil)
        iTunesViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(), tag: 0)
        
        self.documentsViewController = documentsViewController
        self.iTunesViewController = iTunesViewController
        let viewControllers = [documentsViewController, iTunesViewController]
        self.setViewControllers(viewControllers, animated: false)
    }
}
