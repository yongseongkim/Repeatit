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
                self.title = self.encodingMetadataString(string: title)
            }
            if item.commonKey == "artist", let artist = item.stringValue {
                self.artist = self.encodingMetadataString(string: artist)
            }
            if item.commonKey == "albumName", let albumTitle = item.stringValue {
                self.albumTitle = self.encodingMetadataString(string: albumTitle)
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
    }
    
    func encodingMetadataString(string: String) -> String? {
        if let cString = (string as NSString).cString(using: String.Encoding.windowsCP1252.rawValue) {
            let encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
            if let result = NSString(cString: cString, encoding: encoding) as String? {
                return result
            }
        }
        return nil
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
