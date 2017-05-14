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
    var title: String?
    var artist: String?
    var albumTitle: String?
    var artwork: UIImage?
    var lyrics: String?
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
        
        if !File.isAudioFile(url: url) {
            return
        }
        var audioInformation = AudioInformation()
        let playerItem = AVPlayerItem(url: url)
        let metadataList = playerItem.asset.metadata
        for item in metadataList {
            if item.value == nil {
                continue
            }
            if item.commonKey == "title", let title = item.stringValue {
                audioInformation.title = title
            }
            if item.commonKey == "artist", let artist = item.stringValue {
                audioInformation.artist = artist
            }
            if item.commonKey == "albumName", let albumTitle = item.stringValue {
                audioInformation.albumTitle = albumTitle
            }
            if item.commonKey == "artwork", let data = item.dataValue {
                audioInformation.artwork = UIImage(data: data)
            }
            if let key = item.key as? String, let data = item.stringValue {
                if key == "USLT" {
                    audioInformation.lyrics = data
                }
            }
        }
        if (audioInformation.title == nil) {
            audioInformation.title = url.lastPathComponent
        }
        if (audioInformation.artist == nil) {
            audioInformation.artist = "Unkown Artist"
        }
        self.audioInformation = audioInformation
    }
    
    class func isAudioFile(url: URL) -> Bool {
        let supportedFormats = ["aac","adts","ac3","aif","aiff","aifc","caf","mp3","mp4","m4a","snd","au","sd2","wav"]
        if (supportedFormats.contains(url.pathExtension)) {
            return true
        }
        return false
    }
    
    func isEqual(object: Any?) -> Bool {
        if let other = object as? File {
            return self.url.absoluteString == other.url.absoluteString
        }
        return false
    }
}
