//
//  YouTubeVideoFile.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import Foundation

// https://www.youtube.com/watch?v=bNpBoNeGtoA
struct YouTubeItem: Codable {
    static func from(item: PlayItem) -> YouTubeItem? {
        return try? JSONDecoder().decode(YouTubeItem.self, from: Data(contentsOf: item.url))
    }

    let videoId: String
}
