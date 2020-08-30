//
//  WebVTTWriter.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/23.
//

import Foundation

class SimpleWebVTTWriter {
    func convert(title: String, components: [WebVTTComponent]) -> String {
        var result = ""
        if !title.isEmpty {
            result += "WEBVTT - \(title)\n"
        } else {
            result += "WEBVTT\n"
        }
        result += "\n"
        for component in components {
            if let note = component as? WebVTTNote {
                if note.isSingleLine {
                    result += "NOTE \(note.comment)\n"
                } else {
                    result += "NOTE\n"
                    result += note.comment
                    result += "\n"
                }
                result += "\n"
            } else if let cue = component as? WebVTTCue {
                result += cueToString(with: cue)
                result += "\n"
            }
        }
        return result
    }

    private func cueToString(with cue: WebVTTCue) -> String {
        var result = ""
        if let identifier = cue.identifier {
            result += "\(identifier)\n"
        }
        result += "\(applyTimeFormat(millis: cue.startMillis)) --> \(applyTimeFormat(millis: cue.endMillis))"
        if let settings = cue.settings {
            if let vertical = settings.vertical {
                result += " vertical:\(vertical)"
            }
            if let line = settings.line {
                result += " line:\(line)"
            }
            if let position = settings.position {
                result += " position:\(position)"
            }
            if let size = settings.size {
                result += " size:\(size)"
            }
            if let align = settings.align {
                result += " align:\(align)"
            }
        }
        result += "\n"
        result += "\(cue.payload)"
        result += "\n"
        return result
    }

    private func applyTimeFormat(millis: Int) -> String {
        let qnrDividingBy1000 = millis.quotientAndRemainder(dividingBy: 1000)
        let totalSeconds = qnrDividingBy1000.quotient
        let millis = qnrDividingBy1000.remainder
        let qnrDividingBy60 = totalSeconds.quotientAndRemainder(dividingBy: 60)
        let minutes = qnrDividingBy60.quotient
        let seconds = qnrDividingBy60.remainder
        return String(format: "%02d:%02d.%03d", minutes, seconds, millis)
    }
}
