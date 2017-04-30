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
    
    fileprivate var documentsViewController: DocumentAudioFilesViewController?
    fileprivate var iTunesViewController: iTuensSongsViewController?
    fileprivate var playerView: AudioPlayerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let documentsViewController = DocumentAudioFilesViewController()
        documentsViewController.tabBarItem = UITabBarItem(title: "documents", image: UIImage(), tag: 0)
        documentsViewController.displayManager = Dependencies.sharedInstance().resolve(serviceType: FileDisplayManager.self)
        let iTunesViewController = iTuensSongsViewController(nibName: iTuensSongsViewController.className(), bundle: nil)
        iTunesViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(), tag: 0)
        
        self.documentsViewController = documentsViewController
        self.iTunesViewController = iTunesViewController
        let viewControllers = [UINavigationController(rootViewController: documentsViewController), UINavigationController(rootViewController: iTunesViewController)]
        self.setViewControllers(viewControllers, animated: false)

//        if let playerView = Bundle.main.loadNibNamed(AudioPlayerView.className(), owner: nil, options: nil)?.first as? AudioPlayerView {
//            self.playerView = playerView
//            self.view.addSubview(playerView)
//            playerView.snp.makeConstraints({ (make) in
//                make.right.equalTo(self.view)
//                make.bottom.equalTo(self.tabBar.snp.top)
//                make.left.equalTo(self.view)
//                make.height.equalTo(AudioPlayerView.height())
//            })
//        }
    }
}
