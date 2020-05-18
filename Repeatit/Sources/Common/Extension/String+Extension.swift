//
//  String+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/28.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Foundation

extension String {
    func split(usingRegex pattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern)
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map{Range($0.range, in: self)!} + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }

    func getYouTubeId() -> String? {
        guard let _ = URL(string: self) else { return nil }
        let splits = split(usingRegex: "(vi\\/|v=|\\/v\\/|youtu\\.be\\/|\\/embed\\/)")
        if splits.count > 1 {
            let splits2 = splits[1].split(usingRegex: "[^0-9A-Za-z_\\-]")
            return splits2[0]
        } else {
            return splits[0]
        }
    }
}
