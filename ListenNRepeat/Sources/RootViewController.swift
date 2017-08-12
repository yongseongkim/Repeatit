//
//  RootViewController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 2. 5..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer
import SnapKit
import URLNavigator

class RootViewController: UITabBarController {
    
    class func current() -> RootViewController {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.window!.rootViewController as! RootViewController
    }
    
    fileprivate let fileListNaviController = FileListNavigationController()
    fileprivate let itunesNaviController = iTunesNavigationController()
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
        self.fileListNaviController.tabBarItem = UITabBarItem(title: "Files", image: UIImage(named: "menu_documents_28pt"), selectedImage: UIImage(named: "menu_documents_selected_28pt"))
        self.itunesNaviController.tabBarItem = UITabBarItem(title: "iTunes", image: UIImage(named: "menu_itunes_28pt"), selectedImage: UIImage(named: "menu_itunes_selected_28pt"))
        self.moreNaviController.tabBarItem = UITabBarItem(title: "More", image: UIImage(named: "menu_more_28pt"), selectedImage: UIImage(named: "menu_more_selected_28pt"))
        
        let viewControllers = [self.fileListNaviController, self.itunesNaviController, self.moreNaviController]
        self.setViewControllers(viewControllers, animated: false)
    }
    
    func loadPlayerView() {
        self.view.addSubview(self.playerView)
        self.playerView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-UIConstants.TabBarHeight)
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
        self.itunesNaviController.updateContentInset()
        if let moreView = self.moreNaviController.viewControllers.first as? MoreViewController {
            moreView.updateContentInset()
        }
    }
    
    func hidePlayerView() {
        self.playerView.isHidden = true
        self.fileListNaviController.updateContentInset()
        self.itunesNaviController.updateContentInset()
        if let moreView = self.moreNaviController.viewControllers.first as? MoreViewController {
            moreView.updateContentInset()
        }
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
        Navigator.present(playerController, wrap: false, from: self, animated: false, completion: nil)
    }
}
