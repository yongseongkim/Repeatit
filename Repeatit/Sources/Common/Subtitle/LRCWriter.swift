//
//  LRCWriter.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/21.
//

import Foundation

class LRCWriter {
    func convert(metadata: LRCMetadata, lines: [LRCLine]) -> String {
        var result = ""
        let metadataParams = metadata.toParams()
        for key in metadataParams.keys.sorted() {
            result += "[\(key):\(metadataParams[key]!)]\n"
        }
        if !result.isEmpty {
            result += "\n"
        }
        for line in lines {
            let qnrDividingBy1000 = line.millis.quotientAndRemainder(dividingBy: 1000)
            let totalSeconds = qnrDividingBy1000.quotient
            let millis = qnrDividingBy1000.remainder
            let qnrDividingBy60 = totalSeconds.quotientAndRemainder(dividingBy: 60)
            let minutes = qnrDividingBy60.quotient
            let seconds = qnrDividingBy60.remainder
            result += String(format: "[%02d:%02d.%02d]\(line.lyrics)\n", minutes, seconds, Int(millis / 10))
        }
        return result
    }
}
