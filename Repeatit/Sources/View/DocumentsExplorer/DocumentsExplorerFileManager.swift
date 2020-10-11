//
//  DocumentsExplorerFileManager.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/13.
//

import Combine
import Foundation

class DocumentsExplorerFileManager {
    private let changesSubject = PassthroughSubject<URL, Never>()
    var changesPublisher: AnyPublisher<URL, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    func getItems(in url: URL) -> [DocumentsExplorerItem] {
        return FileManager.default.getDocumentItems(in: url)
    }

    func createNewDirectory(in url: URL, dirName: String) {
        do {
            try FileManager.default.createDirectory(
                at: url.appendingPathComponent(dirName),
                withIntermediateDirectories: true,
                attributes: nil
            )
            changesSubject.send(url)
        } catch let exception {
            print(exception)
        }
    }

    func createYouTubeFile(url: URL, videoId: String, fileName: String) {
        let file = YouTubeItem(videoId: videoId)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: url.appendingPathComponent("\(fileName).youtube"))
            changesSubject.send(url)
        } catch let exception {
            print(exception)
        }
    }

    func rename(item: DocumentsExplorerItem, newName: String) {
        let parentDirectoryURL = item.url.deletingLastPathComponent()
        let fromURL = item.url
        let toURL = parentDirectoryURL.appendingPathComponent("\(newName).\(fromURL.pathExtension)")
        do {
            try FileManager.default.moveItem(at: fromURL, to: toURL)
            changesSubject.send(parentDirectoryURL)
        } catch let exception {
            // TODO: handle exception
            print(exception)
        }
    }

    func move(items: [DocumentsExplorerItem], to: URL) {
        var urls = Set<URL>()
        items.forEach { item in
            let fromURL = item.url
            let toURL = to.appendingPathComponent(item.nameWithExtension)
            do {
                try FileManager.default.moveItem(at: fromURL, to: toURL)
                urls.insert(fromURL)
                urls.insert(toURL)
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
        urls.forEach { changesSubject.send($0) }
    }

    func copy(items: [DocumentsExplorerItem], to: URL) {
        copy(urls: items.map { $0.url }, to: to)
    }

    func copy(urls: [URL], to: URL) {
        urls.forEach { url in
            let toURL = to.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: toURL)
                changesSubject.send(to)
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
    }

    func remove(items: [DocumentsExplorerItem]) {
        var urls = Set<URL>()
        items.forEach { item in
            do {
                try FileManager.default.removeItem(at: item.url)
                urls.insert(item.url.deletingLastPathComponent())
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
        urls.forEach { changesSubject.send($0) }
    }
}
