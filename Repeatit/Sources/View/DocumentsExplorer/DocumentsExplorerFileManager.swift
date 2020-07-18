//
//  DocumentsExplorerFileManager.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/13.
//

import Foundation

class DocumentsExplorerFileManager {
    func getItems(in url: URL) -> [DocumentsExplorerItem] {
        return FileManager.default.getDocumentsItems(in: url)
    }

    func createNewDirectory(in url: URL, dirName: String) {
        try? FileManager.default.createDirectory(
            at: url.appendingPathComponent(dirName),
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    func createYouTubeFile(url: URL, videoId: String, fileName: String) {
        let file = YouTubeItem(videoId: videoId)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: url.appendingPathComponent("\(fileName).youtube"))
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
        } catch let exception {
            // TODO: handle exception
            print(exception)
        }
    }

    func move(items: [DocumentsExplorerItem], to: URL) {
        items.forEach { item in
            let fromURL = item.url
            let toURL = to.appendingPathComponent(item.nameWithExtension)
            do {
                try FileManager.default.moveItem(at: fromURL, to: toURL)
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
    }

    func copy(items: [DocumentsExplorerItem], to: URL) {
        copy(urls: items.map { $0.url }, to: to)
    }

    func copy(urls: [URL], to: URL) {
        urls.forEach { url in
            let toURL = to.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: toURL)
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
    }

    func remove(items: [DocumentsExplorerItem]) {
        items.forEach { item in
            do {
                try FileManager.default.removeItem(at: item.url)
            } catch let exception {
                // TODO: handle exception
                print(exception)
            }
        }
    }
}

extension FileManager {
    fileprivate func getDocumentsItems(in url: URL) -> [DocumentsExplorerItem] {
        let files = getFiles(in: url)
        return (
            files.filter { $0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
                + files.filter { !$0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            )
            .map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
    }
}
