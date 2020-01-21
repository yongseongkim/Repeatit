//
//  PlayItem.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/30.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import AVFoundation
import UIKit

// var mediaItem: MPMediaItem?

struct PlayItem {
    let url: URL
    let title: String
    let artist: String
    let albumTitle: String
    let artwork: UIImage
    let lyrics: String

    init(url: URL) {
        self.url = url
        let playerItem = AVPlayerItem(url: self.url)
        let metadataList = playerItem.asset.metadata
        title = metadataList.first { $0.commonKey?.rawValue == "title"}?.stringValue ?? url.lastPathComponent
        artist = metadataList.first { $0.commonKey?.rawValue == "artist"}?.stringValue ?? "Unknown Artist"
        albumTitle = metadataList.first { $0.commonKey?.rawValue == "albumName"}?.stringValue ?? "Unknown Artist"
        let artworkData = metadataList.first { $0.commonKey?.rawValue == "artwork" }?.dataValue
        if let artworkData = artworkData, let artworkImg = UIImage(data: artworkData) {
            artwork = artworkImg
        } else {
            artwork = UIImage(named: "logo_100pt")!
        }
        lyrics = metadataList.first {
            if let key = $0.key as? String, let _ = $0.stringValue {
                return key == "USLT"
            }
            return false
        }?.stringValue ?? ""
    }
}
