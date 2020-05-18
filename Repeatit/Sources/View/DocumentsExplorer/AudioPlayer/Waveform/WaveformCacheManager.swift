//
//  WaveformCacheManager.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/18.
//

import UIKit

class WaveformCacheManager {
    static let shared = WaveformCacheManager()

    var images: [URL: [(WaveformBarStyle, UIImage)]] = [:]

    func get(url: URL, barStyle: WaveformBarStyle, height: CGFloat) -> UIImage? {
        return images[url]?.first(where: { (style, image) -> Bool in
            return style == barStyle && image.size.height == height
        })?.1
    }

    func add(url: URL, barStyle: WaveformBarStyle, image: UIImage) {
        var new = images[url] ?? [(WaveformBarStyle, UIImage)]()
        new.append((barStyle, image))
        images[url] = new
    }

    func remove(url: URL) {
        images[url] = [(WaveformBarStyle, UIImage)]()
    }
}
