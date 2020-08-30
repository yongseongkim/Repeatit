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
        return URL.supportedAuidoFormats.contains(pathExtension)
    }

    var isVideoFile: Bool {
        return URL.supportedVideoFormats.contains(pathExtension)
    }

    var isYouTubeFile: Bool {
        return pathExtension == "youtube"
    }

    var isSupportedSubtitleFile: Bool {
        return URL.supportedSubtitleFormats.contains(pathExtension)
    }

    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }

    var nameWithExtension: String {
        return url.lastPathComponent
    }

    var pathExtension: String {
        return (nameWithExtension as NSString).pathExtension.lowercased()
    }

    var imageName: String {
        if isDirectory {
            return "folder.fill"
        }
        if isAudioFile {
            return "music.note"
        }
        if isVideoFile {
            return "video.fill"
        }
        if isYouTubeFile {
            return "play.rectangle.fill"
        }
        return "doc.text"
    }

    func toAudioItem() -> AudioItem {
        return AudioItem(url: url)
    }

    func toYouTubeItem() -> YouTubeItem {
        guard let item = try? JSONDecoder().decode(YouTubeItem.self, from: Data(contentsOf: url)) else { return YouTubeItem(videoId: "") }
        return item
    }
}

fileprivate extension URL {
    static let supportedFormats = URL.supportedAuidoFormats + URL.supportedVideoFormats
    static let supportedAuidoFormats = ["aac", "adts", "ac3", "aif", "aiff", "aifc", "caf", "mp3", "m4a", "snd", "au", "sd2", "wav"]
    static let supportedVideoFormats = ["mpeg", "avi", "mp4"]
    static let supportedSubtitleFormats = ["lrc", "srt", "vtt"]
}
