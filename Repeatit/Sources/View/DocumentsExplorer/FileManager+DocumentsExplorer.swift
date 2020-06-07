//
//  FileManager+DocumentsExplorer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/07.
//

import Foundation

extension FileManager {
    func getDocumentsItems(in url: URL) -> [DocumentsExplorerItem] {
        let files = getFiles(in: url)
        return (
            files.filter { $0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
                + files.filter { !$0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            )
            .map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
    }
}
