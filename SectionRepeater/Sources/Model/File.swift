//
//  File.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 5. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

struct AudioInformation {
    var url: URL?
    var title: String?
    var artist: String?
    var albumTitle: String?
    var artwork: UIImage?
    var lyrics: String?
    
    init(url: URL) {
        self.url = url
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata
        for item in metadataList {
            if item.value == nil {
                continue
            }
            if item.commonKey == "title", let title = item.stringValue {
                self.title = title
            }
            if item.commonKey == "artist", let artist = item.stringValue {
                self.artist = artist
            }
            if item.commonKey == "albumName", let albumTitle = item.stringValue {
                self.albumTitle = albumTitle
            }
            if item.commonKey == "artwork", let data = item.dataValue {
                self.artwork = UIImage(data: data)
            }
            if let key = item.key as? String, let data = item.stringValue {
                if key == "USLT" {
                    self.lyrics = data
                }
            }
        }
        if (self.title == nil) {
            self.title = url.lastPathComponent
        }
    }
}

class File {
    var url: URL
    var name: String
    var isDirectory: Bool
    var audioInformation: AudioInformation?
    
    init(url: URL, isDirectory:Bool = false) {
        self.url = url
        self.name = url.lastPathComponent
        self.isDirectory = isDirectory
        
        if !url.isPlayerSupported() {
            return
        }
        self.audioInformation = AudioInformation(url: url)
    }

    func isEqual(object: Any?) -> Bool {
        if let other = object as? File {
            return self.url.absoluteString == other.url.absoluteString
        }
        return false
    }
}
