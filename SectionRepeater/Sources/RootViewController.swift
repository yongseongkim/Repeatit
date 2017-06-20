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
    
    fileprivate let fileListNaviController = UINavigationController(rootViewController: FileListViewController())
    fileprivate let itunesListViewController = iTunesListViewController()
    fileprivate let playerView = PlayerView.shared
    fileprivate let player: Player = Dependencies.sharedInstance().resolve(serviceType: Player.self)!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadTabViews()
        self.loadPlayerView()
        self.registerNotification()
    }
    
    func loadTabViews() {
        self.tabBar.tintColor = UIColor.black
        self.fileListNaviController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(named: "empty_common_folder_28pt"), selectedImage: UIImage(named: "fill_common_folder_28pt"))
        self.itunesListViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(named: "empty_music_note_28pt"), selectedImage: UIImage(named: "fill_music_note_28pt"))
        
        let viewControllers = [fileListNaviController, self.itunesListViewController]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    func loadPlayerView() {
        self.view.addSubview(self.playerView)
        self.playerView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-49)
            make.right.equalTo(self.view)
            make.height.equalTo(PlayerView.height())
        }
        self.playerView.isHidden = true
        self.playerView.clipsToBounds = false
        self.playerView.layer.masksToBounds = false
        self.playerView.layer.shadowColor = UIColor.black.cgColor
        self.playerView.layer.shadowOpacity = 1
        self.playerView.layer.shadowOffset = CGSize.zero
        self.playerView.layer.shadowRadius = 10
        self.playerView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: self.view.bounds.height - 49 - PlayerView.height(), width: self.view.bounds.width, height: PlayerView.height())).cgPath
    }
    
    func showPlayerView() {
        self.playerView.isHidden = false
        for vc in self.fileListNaviController.viewControllers {
            if let fileListViewController = vc as? FileListViewController {
                fileListViewController.updateContentInset()
            }
        }
        self.itunesListViewController.updateContentInset()
    }
    
    func hidePlayerView() {
        self.playerView.isHidden = true
        for vc in self.fileListNaviController.viewControllers {
            if let fileListViewController = vc as? FileListViewController {
                fileListViewController.updateContentInset()
            }
        }
        self.itunesListViewController.updateContentInset()
    }
    
    func registerNotification() {
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerItemDidSet(object:)), name: Notification.Name.playerItemDidSet, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerStateUpdatedNotification), name: Notification.Name.playerStateUpdated, object: nil)
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    func handlePlayerItemDidSet(object: Notification) {
        self.playerView.setup()
    }
    
    func handlePlayerStateUpdatedNotification() {
        if self.player.currentItem == nil {
            self.hidePlayerView()
            return
        }
        
        if self.player.state.isPlaying {
            self.showPlayerView()
        }
        self.playerView.setup()
    }
    
    func enterForeground() {
        if self.player.currentItem == nil {
            self.hidePlayerView()
            return
        }
        self.playerView.setup()
    }
}
