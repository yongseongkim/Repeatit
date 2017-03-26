//
//  AVPlayer+Extension.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 3. 23..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
    
    var currentSeconds: Double {
        return self.currentTime().seconds
    }
    
    var durationSeconds: Double {
        if let duration = self.currentItem?.asset.duration {
            return duration.seconds
        }
        return 0.0
    }
    
    func seek(to: Double) {
        self.seek(to: CMTime(seconds: to, preferredTimescale: self.currentTime().timescale))
    }
}

extension AVPlayerItem {
    var url: URL? {
        guard let asset = self.asset as? AVURLAsset else { return nil }
        return asset.url
    }

    open override func isEqual(_ object: Any?) -> Bool {
        guard let another = object as? AVPlayerItem else { return false }
        if let selfURL = self.url, let anotherURL = another.url {
            return selfURL.absoluteString == anotherURL.absoluteString
        }
        return false
    }
}
