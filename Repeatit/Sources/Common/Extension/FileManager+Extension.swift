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
        var isDirectory : ObjCBool = false
        return contents.map { filename in
            let fileURL = url.appendingPathComponent(filename)
            let _ = FileManager.default.fileExists(atPath: fileURL.path, isDirectory: &isDirectory)
            return (url: fileURL, isDir: isDirectory.boolValue)
        }
    }

    func getDocumentsItems(in url: URL) -> [DocumentsExplorerItem] {
        return getFiles(in: url).map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
    }
}
