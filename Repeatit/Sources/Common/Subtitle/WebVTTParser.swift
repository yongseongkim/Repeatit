//
//  WebVTTParser.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/23.
//

import Foundation

class SimpleWebVTTParser {
    enum ParsingError: Error {
        case invalidFormat
    }

    struct Result {
        let title: String
        let components: [WebVTTComponent]
    }
    /*
     WEBVTT - Some title

     NOTE
     Bekind - Marshmello, Halsey
     2020.05.11
     Universal Music Group

     00:06.000 --> 00:07.500 position:100%
     Wanna believe

     00:07.500 --> 00:10.000
     That you don't have a bad bone in your body.

     00:49.000 --> 00:54.000
     You can be kind to the one that you love

     00:56.000 --> 00:58.000

     NOTE This is the last line in the file

     */

    func parse(contents: String) throws -> Result {
        // split contents by blank line.
        let rawComponents = contents.trimmingCharacters(in: .whitespacesAndNewlines).split(usingRegex: "([\r\n]){2,}")
        guard let header = rawComponents.first, header.starts(with: "WEBVTT") else { throw ParsingError.invalidFormat }
        let title = getTitle(from: header) ?? ""
        var components = [WebVTTComponent]()
        // extarct cues and notes
        for idx in 1..<rawComponents.count {
            let rawComponent = rawComponents[idx]
            if let note = getNote(from: rawComponent) {
                components.append(note)
            } else if let cue = getCue(from: rawComponent) {
                components.append(cue)
            }
        }
        return Result(title: title, components: components)
    }

    private func getTitle(from rawComponent: String) -> String? {
        let titleRegex = try? NSRegularExpression(pattern: "WEBVTT(\\s*\\-\\s*)(?<title>.+)")
        guard let matchOfTitle = titleRegex?.firstMatch(in: rawComponent, options: [], range: .init(rawComponent.startIndex..., in: rawComponent)) else { return nil }
        return rawComponent.substring(with: matchOfTitle.range(withName: "title"))
    }

    private func getCue(from rawComponent: String) -> WebVTTCue? {
        let cueRegex = try? NSRegularExpression(pattern: "(?<identifier>.*)\\n*(?<startMinutes>\\d{2}):(?<startSeconds>\\d{2}).(?<startMillis>\\d+) --> (?<endMinutes>\\d{2}):(?<endSeconds>\\d{2}).(?<endMillis>\\d+)(?<settings>.*)\\n*(?<payload>(.|\\n|\\r)*)", options: .caseInsensitive)
        guard let matchOfCue = cueRegex?.firstMatch(in: rawComponent, options: [], range: .init(rawComponent.startIndex..., in: rawComponent)) else { return nil }
        let identifier = rawComponent.substring(with: matchOfCue.range(withName: "identifier"))
        guard let startMillis = getMillis(
            minutes: rawComponent.substring(with: matchOfCue.range(withName: "startMinutes")),
            seconds: rawComponent.substring(with: matchOfCue.range(withName: "startSeconds")),
            millis: rawComponent.substring(with: matchOfCue.range(withName: "startMillis"))
        ) else { return nil }
        guard let endMillis = getMillis(
            minutes: rawComponent.substring(with: matchOfCue.range(withName: "endMinutes")),
            seconds: rawComponent.substring(with: matchOfCue.range(withName: "endSeconds")),
            millis: rawComponent.substring(with: matchOfCue.range(withName: "endMillis"))
        ) else { return nil }
        let settings = rawComponent.substring(with: matchOfCue.range(withName: "settings"))
        let payload = rawComponent.substring(with: matchOfCue.range(withName: "payload"))
        return WebVTTCue(
            identifier: identifier,
            startMillis: startMillis,
            endMillis: endMillis,
            payload: payload,
            settings: getCueSettings(from: settings)
        )
    }

    private func getCueSettings(from rawString: String) -> WebVTTCue.Settings? {
        guard !rawString.isEmpty else { return nil }
        var vertical: String?
        var line: String?
        var position: String?
        var size: String?
        var align: String?
        for rawSetting in rawString.split(separator: " ") {
            let keyValue = rawSetting.split(separator: ":")
            if let key = keyValue.first, keyValue.count > 1 {
                let value = String(keyValue[1])
                switch key {
                case "vertical":
                    vertical = value
                case "line":
                    line = value
                case "position":
                    position = value
                case "size":
                    size = value
                case "align":
                    align = value
                default:
                    break
                }
            }
        }
        return .init(vertical: vertical, line: line, position: position, size: size, align: align)
    }

    private func getNote(from rawComponent: String) -> WebVTTNote? {
        let noteRegex = try? NSRegularExpression(pattern: "NOTE(\\r|\\n|\\s)+(?<comment>(.|\\n|\\r)*)")
        guard let matchOfComment = noteRegex?.firstMatch(in: rawComponent, options: [], range: .init(rawComponent.startIndex..., in: rawComponent)) else { return nil }
        return WebVTTNote(comment: rawComponent.substring(with: matchOfComment.range(withName: "comment")))
    }

    private func getMillis(minutes: String, seconds: String, millis: String) -> Int? {
        guard let minutes = Int(minutes), let seconds = Int(seconds), let millis = Int(millis) else { return nil }
        return (minutes * 60 + seconds) * 1000 + millis
    }
}
