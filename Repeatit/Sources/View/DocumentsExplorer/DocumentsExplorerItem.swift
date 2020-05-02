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
        return "doc.text"
    }
}
