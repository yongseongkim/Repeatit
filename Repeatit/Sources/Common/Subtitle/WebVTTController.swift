//
//  WebVTTController.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/26.
//

import Combine
import Foundation

class WebVTTController {
    var cues: [WebVTTCue] { _cues }
    var changesPublisher: AnyPublisher<Void, Never> { changesSubject.eraseToAnyPublisher() }
    var notes: [WebVTTNote] { _notes.map { $0.1 } }
    var components: [WebVTTComponent] {
        var cmps: [WebVTTComponent] = _cues
        _notes.forEach { (idx, note) in
            cmps.insert(note, at: idx >= cmps.count ? cmps.count : idx)
        }
        return cmps
    }

    private let parser = SimpleWebVTTParser()
    private let writer = SimpleWebVTTWriter()

    private let syncQueue = DispatchQueue(label: "vttSyncQueue")
    private var syncQueueItems = [DispatchWorkItem]()
    private let url: URL
    private let title: String
    private let duration: Int

    private var _cues: [WebVTTCue]
    private var _notes: [(Int, WebVTTNote)]
    private let changesSubject = PassthroughSubject<Void, Never>()

    init(url: URL, duration: Int) {
        self.url = url
        self.duration = duration
        self._cues = []
        self._notes = []
        if let contents = try? String(contentsOf: url), let result = try? parser.parse(contents: contents) {
            title = result.title
            for idx in 0..<result.components.count {
                let component = result.components[idx]
                if let cue = component as? WebVTTCue {
                    _cues.append(cue)
                } else if let note = component as? WebVTTNote {
                    _notes.append((idx, note))
                }
            }
        } else {
            FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
            title  = url.lastPathComponent
        }
    }

    deinit {
        syncQueueItems.forEach { $0.cancel() }
    }

    func addCue(at millis: Int) {
        // Do not add same time cue.
        if _cues.contains(where: { $0.startMillis == millis}) {
            return
        }
        // find index for insertion.
        let idx = _cues.firstIndex { $0.startMillis > millis } ?? _cues.count
        var newEndMillis = duration
        if idx < _cues.count {
            newEndMillis = _cues[idx].startMillis
        }
        let new = WebVTTCue(startMillis: millis, endMillis: newEndMillis, payload: "")
        _cues.insert(new, at: idx)
        if idx - 1 >= 0 {
            let prev = _cues[idx - 1]
            if new.startMillis < prev.endMillis {
                _cues[idx - 1] = prev.update(endMillis: new.startMillis)
            }
        }
        changesSubject.send(())
        sync()
    }

    func removeCue(at millis: Int) {
        for idx in 0..<_cues.count where millis == _cues[idx].startMillis {
            _cues.remove(at: idx)
            changesSubject.send(())
        }
        sync()
    }

    func updateCue(at millis: Int, payload: String) {
        for idx in 0..<_cues.count {
            let cue = _cues[idx]
            if cue.startMillis == millis {
                if cue.payload == payload {
                    // If there are no changes, skip.
                    return
                }
                _cues[idx] = cue.update(payload: payload)
                changesSubject.send(())
                break
            }
        }
        sync()
    }

    private func sync() {
        syncQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            do {
                let result = self.writer.convert(title: self.title, components: self.components)
                try result.write(toFile: self.url.path, atomically: true, encoding: .utf8)
                print("sync success: \(result)")
            } catch let exception {
                print(exception)
            }
        })
    }
}
