//
//  AudioItem.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 6..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioItem: NSObject {
    var fileURL: URL
    var title: String?
    var artist: String?
    var albumTitle: String?
    var artwork: UIImage?
    var lyrics: String?
    
    init(url: URL) {
        self.fileURL = url
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata
        for item in metadataList {
            if item.commonKey == nil || item.value == nil {
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
            if item.commonKey == "lyrics", let lyrics = item.stringValue {
                self.lyrics = lyrics
            }
        }
        if (self.title == nil) {
            self.title = url.lastPathComponent
        }
        if (self.artist == nil) {
            self.artist = "Unkown Artist"
        }
    }
    
    class func isAudioFile(url: URL) -> Bool {
        let supportedFormats = ["aac","adts","ac3","aif","aiff","aifc","caf","mp3","mp4","m4a","snd","au","sd2","wav"]
        if (supportedFormats.contains(url.pathExtension)) {
            return true
        }
        return false
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? AudioItem {
            return self.fileURL.absoluteString == other.fileURL.absoluteString
        }
        return false
    }
}
