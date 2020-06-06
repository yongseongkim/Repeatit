//
//  YouTubeVideoFile.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import Foundation

// https://www.youtube.com/watch?v=bNpBoNeGtoA
struct YouTubeVideoItem: Codable {
    static func from(item: PlayItem) -> YouTubeVideoItem? {
        return try? JSONDecoder().decode(YouTubeVideoItem.self, from: Data(contentsOf: item.url))
    }

    let videoId: String
}
