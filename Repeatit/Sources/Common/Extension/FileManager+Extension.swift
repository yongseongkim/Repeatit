//
//  FileManager+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import Foundation

extension FileManager {
    func getFiles(in url: URL) -> [(url: URL, isDir: Bool)] {
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? [String]()
        var isDirectory: ObjCBool = false
        return contents.map { filename in
            let fileURL = url.appendingPathComponent(filename)
            FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            return (url: fileURL, isDir: isDirectory.boolValue)
        }
    }

    func getDocumentItems(in url: URL) -> [DocumentsExplorerItem] {
        let files = getFiles(in: url)
        return (
            files.filter { $0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
                + files.filter { !$0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            )
            .map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
    }
}
