//
//  SRTWriter.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/23.
//

import Foundation

class SRTWriter {
    func convert(components: [SRTComponent]) -> String {
        let sorted = components.sorted { $0.startMillis < $1.startMillis }
        var result = ""
        if let first = sorted.first {
            result += "1\n"
            result += "\(applyTimeFormat(millis: first.startMillis)) --> \(applyTimeFormat(millis: first.endMillis))\n"
            result += "\(first.caption)\n"
        }
        for idx in 1..<sorted.count {
            let component = sorted[idx]
            result += "\n"
            result += "\(idx + 1)\n"
            result += "\(applyTimeFormat(millis: component.startMillis)) --> \(applyTimeFormat(millis: component.endMillis))\n"
            result += "\(component.caption)\n"
        }
        return result
    }

    private func applyTimeFormat(millis: Int) -> String {
        let qnrDividingBy1000 = millis.quotientAndRemainder(dividingBy: 1000)
        let totalSeconds = qnrDividingBy1000.quotient
        let millis = qnrDividingBy1000.remainder
        let qnrDividingBy3600 = totalSeconds.quotientAndRemainder(dividingBy: 3600)
        let hours = qnrDividingBy3600.quotient
        let qnrDividingBy60 = qnrDividingBy3600.remainder.quotientAndRemainder(dividingBy: 60)
        let minutes = qnrDividingBy60.quotient
        let seconds = qnrDividingBy60.remainder
        return String(format: "%02d:%02d:%02d,%03d", hours, minutes, seconds, millis)
    }
}
