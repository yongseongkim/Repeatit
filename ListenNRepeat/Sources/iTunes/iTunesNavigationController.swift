//
//  iTunesNavigationController.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class iTunesNavigationController : UINavigationController {
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setViewControllers([iTunesViewController()], animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateContentInset() {
        for vc in self.viewControllers {
            if let menuList = vc as? iTunesViewController {
                menuList.updateContentInset()
            }
            if let songList = vc as? iTunesSongListViewController {
                songList.updateContentInset()
            }
            if let albumList = vc as? iTunesSongListViewController {
                albumList.updateContentInset()
            }
            if let artistList = vc as? iTunesSongListViewController {
                artistList.updateContentInset()
            }
            if let playlist = vc as? iTunesPlaylistViewController {
                playlist.updateContentInset()
            }
        }
    }
}
