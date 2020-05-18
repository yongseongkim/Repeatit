//
//  DocumentsExplorerItem.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerItem: Hashable, Codable {
    var url: URL
    var isDirectory: Bool
}

extension DocumentsExplorerItem: Identifiable {
    var id: String {
        return url.absoluteString
    }

    var isAudioFile: Bool {
        return URL.supportedFormats.contains((name as NSString).pathExtension)
    }

    var isYouTubeFile: Bool {
        return (name as NSString).pathExtension == "youtube"
    }

    var name: String {
        return url.lastPathComponent
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
