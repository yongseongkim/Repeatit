//
//  DocumentsExplorerItem.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerItem: Hashable, Codable {
    let url: URL
    let isDirectory: Bool

    init(url: URL, isDirectory: Bool = false) {
        self.url = url
        self.isDirectory = isDirectory
    }
}

extension DocumentsExplorerItem: PlayItem {
}

extension DocumentsExplorerItem: Identifiable {
    var id: String {
        return url.absoluteString
    }

    var isAudioFile: Bool {
        return URL.supportedFormats.contains(pathExtension)
    }

    var isYouTubeFile: Bool {
        return pathExtension == "youtube"
    }

    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }

    var nameWithExtension: String {
        return url.lastPathComponent
    }

    var pathExtension: String {
        return (nameWithExtension as NSString).pathExtension
    }

    var imageName: String {
        if isDirectory {
            return "folder"
        }
        if isAudioFile {
            return "music.note"
        }
        if isYouTubeFile {
            return "play.rectangle.fill"
        }
        return "doc.text"
    }

    func toAudioItem() -> AudioItem {
        return AudioItem(url: url)
    }

    func toYouTubeItem() -> YouTubeVideoItem {
        guard let item = try? JSONDecoder().decode(YouTubeVideoItem.self, from: Data(contentsOf: url)) else { return YouTubeVideoItem(videoId: "") }
        return item
    }
}

fileprivate extension URL {
    static let supportedFormats = ["aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp3", "mp4", "m4a", "snd", "au", "sd2", "wav"]
}
