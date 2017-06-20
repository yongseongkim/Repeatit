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
import SwiftyImage
import RealmSwift

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
    
    class func rename(file: File, rename: String) {
        do {
            let targetURL = URL(fileURLWithPath: String(format: "%@/%@", file.url.deletingLastPathComponent().path, rename))
            try FileManager.default.moveItem(at: file.url, to: targetURL)
            let realm = try! Realm()
            if let oldObj = realm.objects(BookmarkObject.self).filter("path = '\(file.url.bookmarkKey())'").first {
                try! realm.write {
                    // 삭제하고 새로 만들면 invalidate error나기 때문에 times 옮긴 후 삭제해야 한다.
                    realm.beginWrite()
                    let newObj = BookmarkObject(path: targetURL.bookmarkKey())
                    oldObj.times.forEach({ (time) in
                        newObj.times.append(time)
                    })
                    realm.delete(oldObj)
                    realm.create(BookmarkObject.self, value: newObj, update: true)
                    try realm.commitWrite()
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    class func move(files: [File], targetURL: URL) {
        let realm = try! Realm()
        for file in files {
            let from = file.url
            if !FileManager.default.fileExists(atPath: from.path) {
                continue
            }
            do {
                let moveTo = targetURL.appendingPathComponent(from.lastPathComponent)
                try FileManager.default.moveItem(atPath: from.path, toPath: moveTo.path)
                if let oldObj = realm.objects(BookmarkObject.self).filter("path = '\(from.bookmarkKey())'").first {
                    // 삭제하고 새로 만들면 invalidate error나기 때문에 times 옮긴 후 삭제해야 한다.
                    realm.beginWrite()
                    let newObj = BookmarkObject(path: moveTo.bookmarkKey())
                    oldObj.times.forEach({ (time) in
                        newObj.times.append(time)
                    })
                    realm.delete(oldObj)
                    realm.create(BookmarkObject.self, value: newObj, update: true)
                    try realm.commitWrite()
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    class func delete(files: [File]) {
        for file in files {
            do {
                try FileManager.default.removeItem(at: file.url)
                let realm = try! Realm()
                if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(file.url.bookmarkKey)'").first {
                    realm.delete(bookmarkObj)
                }
            } catch let error {
                print(error)
            }
        }
    }
}
