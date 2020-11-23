//
//  DocumentMetadata.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import UIKit
import AVFoundation

struct MediaMetadata {
    let title: String
    let artist: String
    let albumTitle: String
    let artwork: UIImage
    let lyrics: String

    init(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata
        title = metadataList.first { $0.commonKey?.rawValue == "title" }?.stringValue ?? url.lastPathComponent
        artist = metadataList.first { $0.commonKey?.rawValue == "artist" }?.stringValue ?? "Unknown Artist"
        albumTitle = metadataList.first { $0.commonKey?.rawValue == "albumName" }?.stringValue ?? "Unknown Artist"
        let artworkData = metadataList.first { $0.commonKey?.rawValue == "artwork" }?.dataValue
        if let artworkData = artworkData, let artworkImg = UIImage(data: artworkData) {
            artwork = artworkImg
        } else {
            artwork = UIImage(named: "logo_100pt")!
        }
        lyrics = metadataList.first {
            if let key = $0.key as? String, $0.stringValue != nil {
                return key == "USLT"
            }
            return false
        }?.stringValue ?? ""
    }
}
