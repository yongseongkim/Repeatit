//
//  SimpleWebVTTComponent.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/25.
//

import Foundation

protocol WebVTTComponent {}

struct WebVTTCue: WebVTTComponent {
    // The payload text may contain newlines but it cannot contain a blank line, which is equivalent to two consecutive newlines.
    // A blank line signifies the end of a cue.
    // A cue text payload cannot contain the string "-->"
    struct Settings {
        let vertical: String?
        let line: String?
        let position: String?
        let size: String?
        let align: String?

        init(vertical: String? = nil, line: String? = nil, position: String? = nil, size: String? = nil, align: String? = nil) {
            self.vertical = vertical
            self.line = line
            self.position = position
            self.size = size
            self.align = align
        }
    }

    let identifier: String?
    let startMillis: Int
    let endMillis: Int
    let payload: String
    let settings: Settings?

    init(identifier: String? = nil, startMillis: Int, endMillis: Int, payload: String, settings: Settings? = nil) {
        self.identifier = identifier
        self.startMillis = startMillis
        self.endMillis = endMillis
        self.payload = payload
        self.settings = settings
    }

    func update(
        identifier: String? = nil,
        startMillis: Int? = nil,
        endMillis: Int? = nil,
        payload: String? = nil,
        settings: Settings? = nil
    ) -> WebVTTCue {
        return WebVTTCue(
            identifier: identifier ?? self.identifier,
            startMillis: startMillis ?? self.startMillis,
            endMillis: endMillis ?? self.endMillis,
            payload: payload ?? self.payload,
            settings: settings ?? self.settings
        )
    }
}

struct WebVTTNote: WebVTTComponent {
    let comment: String

    var isSingleLine: Bool {
        return !comment.contains("\n")
    }
}
