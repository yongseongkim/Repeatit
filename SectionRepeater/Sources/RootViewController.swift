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
import URLNavigator

class RootViewController: UITabBarController {
    
    fileprivate let fileListNaviController = FileListNavigationController()
    fileprivate let itunesListViewController = iTunesListViewController()
    fileprivate let moreNaviController = UINavigationController(rootViewController: MoreViewController())
    fileprivate let playerView = PlayerView.shared
    
    deinit {
        self.removeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
        self.loadTabViews()
        self.loadPlayerView()
        self.registerNotification()
    }
    
    func registerNotification() {
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handlePlayerItemDidSet(object:)), name: Notification.Name.playerItemDidSet, object: nil)
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handlePlayerStateUpdatedNotification), name: Notification.Name.playerStateUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func removeNotification() {
        Player.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadTabViews() {
        self.tabBar.tintColor = UIColor.black
        self.fileListNaviController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(named: "empty_common_folder_28pt"), selectedImage: UIImage(named: "fill_common_folder_28pt"))
        self.itunesListViewController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(named: "empty_music_note_28pt"), selectedImage: UIImage(named: "fill_music_note_28pt"))
        self.moreNaviController.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "btn_common_option_44pt"), selectedImage: UIImage(named: "btn_common_option_44pt"))
        
        let viewControllers = [self.fileListNaviController, self.itunesListViewController, self.moreNaviController]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    func loadPlayerView() {
        self.view.addSubview(self.playerView)
        self.playerView.snp.makeConstraints { (make) in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-UIConstants.TabBarHeight)
            make.right.equalTo(self.view)
            make.height.equalTo(PlayerView.height())
        }
        self.playerView.isHidden = true
        self.playerView.delegate = self
    }
    
    func showPlayerView() {
        if (PlayerView.isVisible()) {
            return
        }
        self.playerView.isHidden = false
        self.playerView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.playerView.alpha = 1
        }
        self.fileListNaviController.updateContentInset()
        self.itunesListViewController.updateContentInset()
    }
    
    func hidePlayerView() {
        self.playerView.isHidden = true
        self.fileListNaviController.updateContentInset()
        self.itunesListViewController.updateContentInset()
    }
    
    //MARK: Handle Notification
    func handlePlayerItemDidSet(object: Notification) {
        if Player.shared.currentItem == nil {
            self.hidePlayerView()
            return
        }
        self.playerView.setup()
    }
    
    func handlePlayerStateUpdatedNotification() {
        if Player.shared.currentItem == nil {
            self.hidePlayerView()
            return
        }
        if Player.shared.state.isPlaying {
            self.showPlayerView()
        }
        self.playerView.setup()
    }
    
    func enterForeground() {
        if Player.shared.currentItem == nil {
            self.hidePlayerView()
            return
        }
        self.playerView.setup()
    }
}

extension RootViewController: PlayerViewDelegate {
    func playerViewTapped() {
        let playerController = PlayerViewController(nibName: PlayerViewController.className(), bundle: nil)
        playerController.modalPresentationStyle = .custom
        Navigator.present(playerController)
    }
}
