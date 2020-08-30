//
//  LRCParser.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/19.
//

import Foundation

class LRCParser {
    struct Result {
        let metadata: LRCMetadata
        let lines: [LRCLine]
    }

    func parse(contents: String) -> Result {
        let rows = contents.components(separatedBy: "\n")
        var metadataParams = [String: String]()
        var lines = [LRCLine]()
        for row in rows {
            // Ignore whitespace lines.
            let whitespaceFiltered = row.replacingOccurrences(of: "[\\s]+", with: "", options: .regularExpression, range: nil)
            if whitespaceFiltered.isEmpty {
                continue
            }
            let metadataRegex = try? NSRegularExpression(pattern: "\\[(?<key>[a-z]+):(?<value>.+)\\]", options: .caseInsensitive)
            if let matchOfMetadata = metadataRegex?.firstMatch(in: row, options: [], range: .init(row.startIndex..., in: row)) {
                let metadataKey = row.substring(with: matchOfMetadata.range(withName: "key"))
                let metadataValue = row.substring(with: matchOfMetadata.range(withName: "value"))
                metadataParams[metadataKey] = metadataValue
            } else {
                let timeFormatRegex = try? NSRegularExpression(pattern: "\\[(?<minutes>\\d{2}):(?<seconds>\\d{2}).(?<remainder>\\d{2})\\](?<lyrics>.*)", options: .caseInsensitive)
                if let matchOfLyrics = timeFormatRegex?.firstMatch(in: row, options: [], range: .init(row.startIndex..., in: row)) {
                    let minutes = Int(row.substring(with: matchOfLyrics.range(withName: "minutes"))) ?? 0
                    let seconds = Int(row.substring(with: matchOfLyrics.range(withName: "seconds"))) ?? 0
                    let remainder = Int(row.substring(with: matchOfLyrics.range(withName: "remainder"))) ?? 0
                    let lyrics = row.substring(with: matchOfLyrics.range(withName: "lyrics"))
                    lines.append(LRCLine(millis: (minutes * 60 + seconds) * 1000 + (remainder * 10), lyrics: lyrics))
                }
            }
        }
        return Result(
            metadata: .init(params: metadataParams),
            lines: lines.sorted(by: { $0.millis < $1.millis}
            )
        )
    }
}
