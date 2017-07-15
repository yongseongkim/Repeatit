//
//  iTunesListViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 6. 12..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class iTunesListViewController : UINavigationController {
    public let songListViewController = iTunesSongListViewController()
    public let albumListViewController = iTunesAlbumListViewController()
    public let artistListViewController = iTunesArtistListViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.setViewControllers([songListViewController], animated: false)
        self.songListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(switchViewController))
        self.albumListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(switchViewController))
        self.artistListViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Switch", style: .plain, target: self, action: #selector(switchViewController))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func switchViewController() {
        guard let visibleViewController = self.visibleViewController else { return }
        let orders = [songListViewController, albumListViewController, artistListViewController]
        if let index = orders.index(of: visibleViewController) {
            self.setViewControllers([orders[(index + 1) % orders.count]], animated: false)
        }
    }
    
    public func updateContentInset() {
        for vc in self.viewControllers {
            if let songList = vc as? iTunesSongListViewController {
                songList.updateContentInset()
            }
            if let albumList = vc as? iTunesSongListViewController {
                albumList.updateContentInset()
            }
            if let artistList = vc as? iTunesSongListViewController {
                artistList.updateContentInset()
            }
        }
    }
}
