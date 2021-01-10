//
//  LRCController.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/21.
//

import Combine
import Foundation

class LRCController {
    var lines: [LRCLine] { _lines }
    var changesPublisher: AnyPublisher<[LRCLine], Never> {
        changesSubject.eraseToAnyPublisher()
    }

    private let parser = LRCParser()
    private let writer = LRCWriter()

    private let syncQueue = DispatchQueue(label: "lrcSyncQueue")
    private let url: URL
    private let metadata: LRCMetadata

    private var _lines: [LRCLine]
    private let changesSubject = PassthroughSubject<[LRCLine], Never>()

    init(url: URL) {
        self.url = url
        if let contents = try? String(contentsOf: url) {
            let result = parser.parse(contents: contents)
            metadata = result.metadata
            _lines = result.lines
        } else {
            FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
            metadata = LRCMetadata()
            _lines = []
        }
    }

    func addLine(at millis: Int) {
        // Do not add same time line.
        if _lines.contains(where: { $0.millis == millis }) {
            return
        }
        let idx = _lines.firstIndex(where: { $0.millis > millis}) ?? _lines.count
        _lines.insert(LRCLine(millis: millis, lyrics: ""), at: idx)
        changesSubject.send(_lines)
        sync()
    }

    func removeLine(at millis: Int) {
        guard let idx = _lines.firstIndex(where: { $0.millis == millis }) else { return }
        _lines.remove(at: idx)
        changesSubject.send(_lines)
        sync()
    }

    func updateLine(at millis: Int, lyrics: String) {
        for i in 0..<_lines.count {
            let line = _lines[i]
            if millis == line.millis {
                if line.lyrics == lyrics {
                    // If there are no changes, skip.
                    return
                }
                _lines[i] = line.update(lyrics: lyrics)
                changesSubject.send(_lines)
                break
            }
        }
        sync()
    }

    private func sync() {
        syncQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            do {
                let result = self.writer.convert(metadata: self.metadata, lines: self._lines)
                try result.write(toFile: self.url.path, atomically: true, encoding: .utf8)
                if BuildConfig.isDebug {
                    print("LRCController saved the result: \n\(result)")
                }
            } catch let exception {
                print(exception)
            }
        })
    }
}
