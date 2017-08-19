//
//  PlayerItem.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 5. 28..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import MediaPlayer

class PlayerItem: NSObject {
    var fileItem: File?
    var mediaItem: MPMediaItem?
    
    lazy var url: URL? = { [weak self] in
        if let media = self?.mediaItem, let mediaURL = media.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
            return mediaURL
        }
        return self?.fileItem?.url
    }()
    lazy var bookmarkKey: String? = { [weak self] in
        guard let targetURL = self?.url else { return nil }
        guard let range = targetURL.path.range(of: URL.documentsURL.path) else { return targetURL.absoluteString }
        var result = targetURL.path
        result.removeSubrange(range)
        return result
    }()
    
    var title: String?
    var artist: String?
    var albumTitle: String?
    var artwork: UIImage?
    var lyrics: String?
    
    open override func isEqual(_ object: Any?) -> Bool {
        guard let another = object as? PlayerItem else { return false }
        if let selfURL = self.url, let anotherURL = another.url {
            return selfURL.absoluteString == anotherURL.absoluteString
        }
        return false
    }

    static func items(files: [File]) -> [PlayerItem] {
        var list = [PlayerItem]()
        for file in files {
            let item = PlayerItem()
            item.fileItem = file
            if let info = file.audioInformation {
                item.title = info.title
                item.artist = info.artist
                item.albumTitle = info.albumTitle
                item.artwork = info.artwork
                item.lyrics = info.lyrics
            }
            list.append(item)
        }
        return list
    }

    static func items(mediaItems: [MPMediaItem]) -> [PlayerItem] {
        var list = [PlayerItem]()
        for mediaItem in mediaItems {
            let item = PlayerItem()
            item.mediaItem = mediaItem
            item.title = mediaItem.title
            item.artist = mediaItem.artist
            item.albumTitle = mediaItem.albumTitle
            if let artwork = mediaItem.artwork {
                item.artwork = artwork.image(at: artwork.bounds.size)
            }
            item.lyrics = mediaItem.lyrics
            list.append(item)
        }
        return list
    }
}

