//
//  SRTParser.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/23.
//

import Foundation

class SRTParser {
    struct Result {
        let components: [SRTComponent]
    }
    /*
     1
     00:00:06,000 --> 00:00:07,500
     Wanna believe

     2
     00:00:07,500 --> 00:00:10,000
     That you don't have a bad bone in your body.

     3
     00:00:10,000 --> 00:00:12,000
     But the bruises on your ego make you go wild, wild
     */

    func parse(contents: String) -> Result {
        // split contents by blank line.
        let rawComponents = contents.trimmingCharacters(in: .whitespacesAndNewlines).split(usingRegex: "([\r\n]){2,}")
        var components = [SRTComponent]()
        for rawComponent in rawComponents {
            if let srtComponent = parse(rawComponent: rawComponent) {
                components.append(srtComponent)
            }
        }
        return Result(components: components.sorted { $0.startMillis < $1.startMillis })
    }

    private func parse(rawComponent: String) -> SRTComponent? {
        guard let srtRegex = try? NSRegularExpression(
            pattern: "(\\d+)\\n(?<sh>\\d{2}):(?<smins>\\d{2}):(?<ss>\\d{2}).(?<sms>\\d+) --> (?<eh>\\d{2}):(?<emins>\\d{2}):(?<es>\\d{2}).(?<ems>\\d+)\\n*(?<caption>.*)",
            options: .caseInsensitive
            ) else { return nil }
        guard let matchOfSrt = srtRegex.firstMatch(in: rawComponent, options: [], range: .init(rawComponent.startIndex..., in: rawComponent)) else { return nil }
        guard let startMillis = getMillis(
            hours: rawComponent.substring(with: matchOfSrt.range(withName: "sh")),
            minutes: rawComponent.substring(with: matchOfSrt.range(withName: "smins")),
            seconds: rawComponent.substring(with: matchOfSrt.range(withName: "ss")),
            millis: rawComponent.substring(with: matchOfSrt.range(withName: "sms"))
            ) else { return nil }
        guard let endMillis = getMillis(
            hours: rawComponent.substring(with: matchOfSrt.range(withName: "eh")),
            minutes: rawComponent.substring(with: matchOfSrt.range(withName: "emins")),
            seconds: rawComponent.substring(with: matchOfSrt.range(withName: "es")),
            millis: rawComponent.substring(with: matchOfSrt.range(withName: "ems"))
            ) else { return nil }
        return SRTComponent(
            startMillis: startMillis,
            endMillis: endMillis,
            caption: rawComponent.substring(with: matchOfSrt.range(withName: "caption"))
        )
    }

    private func getMillis(hours: String, minutes: String, seconds: String, millis: String) -> Int? {
        guard let hours = Int(hours), let minutes = Int(minutes), let seconds = Int(seconds), let millis = Int(millis) else { return nil }
        return ((hours * 60 + minutes) * 60 + seconds) * 1000 + millis
    }
}
