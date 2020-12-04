//
//  SRTController.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/23.
//

import Combine
import Foundation

class SRTController {
    var components: [SRTComponent] { _components }
    var changesPublisher: AnyPublisher<[SRTComponent], Never> {
        changesSubject.eraseToAnyPublisher()
    }

    private let parser = SRTParser()
    private let writer = SRTWriter()

    private let syncQueue = DispatchQueue(label: "srtSyncQueue")
    private var syncQueueItems = [DispatchWorkItem]()
    private let url: URL
    private let duration: Int

    private var _components: [SRTComponent]
    private let changesSubject = PassthroughSubject<[SRTComponent], Never>()

    init(url: URL, duration: Int) {
        self.url = url
        self.duration = duration
        if let contents = try? String(contentsOf: url) {
            let result = parser.parse(contents: contents)
            _components = result.components
        } else {
            FileManager.default.createFile(atPath: url.path, contents: Data(), attributes: nil)
            _components = []
        }
    }

    deinit {
        syncQueueItems.forEach { $0.cancel() }
    }

    func addComponent(at millis: Int) {
        if _components.contains(where: { $0.startMillis == millis}) {
            return
        }
        // find index for insertion.
        let idx = _components.firstIndex(where: { $0.startMillis > millis}) ?? _components.count
        var newEndMillis = duration
        if idx < _components.count {
            newEndMillis = _components[idx].startMillis
        }
        let new = SRTComponent(startMillis: millis, endMillis: newEndMillis, caption: "")
        _components.insert(new, at: idx)
        if idx - 1 >= 0 {
            let prev = _components[idx - 1]
            if new.startMillis < prev.endMillis {
                _components[idx - 1] = prev.update(endMillis: new.startMillis)
            }
        }
        changesSubject.send(_components)
        sync()
    }

    func removeComponent(at millis: Int) {
        guard let idx = _components.firstIndex(where: { $0.startMillis == millis }) else { return }
        _components.remove(at: idx)
        changesSubject.send(_components)
        sync()
    }

    func updateComponent(at millis: Int, caption: String) {
        for idx in 0..<_components.count {
            let component = components[idx]
            if component.startMillis == millis {
                if component.caption == caption {
                    // If there are no changes, skip.
                    return
                }
                _components[idx] = _components[idx].update(caption: caption)
                changesSubject.send(_components)
                break
            }
        }
        sync()
    }

    private func syncMillisAdjacent(to: Int) {
        let center = _components[to]
        if to - 1 >= 0 {
            let prev = _components[to - 1]
            _components[to - 1] = SRTComponent(startMillis: prev.startMillis, endMillis: center.startMillis, caption: prev.caption)
        }
        if to + 1 <= _components.count - 1 {
            let next = _components[to + 1]
            _components[to + 1] = SRTComponent(startMillis: next.startMillis, endMillis: next.endMillis, caption: next.caption)
        }
    }

    private func sync() {
        syncQueue.async(execute: { [weak self] in
            guard let self = self else { return }
            do {
                let result = self.writer.convert(components: self.components)
                try result.write(toFile: self.url.path, atomically: true, encoding: .utf8)
                if BuildConfig.isDebug {
                    print("SRTController saved the result: \n\(result)")
                }
            } catch let exception {
                print(exception)
            }
        })
    }
}
