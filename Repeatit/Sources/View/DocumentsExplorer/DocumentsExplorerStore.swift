//
//  DocumentsExplorerStore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/15.
//

import Combine
import Foundation
import RealmSwift

class DocumentsExplorerStore: ObservableObject {
    @Published var items: [URL: [DocumentsExplorerItem]]
    @Published var isEditing = false {
        didSet {
            if !isEditing {
                selectedItems = []
            }
        }
    }
    @Published var selectedItem: DocumentsExplorerItem?
    @Published var isDestinationViewShowingForCopy: Bool = false
    @Published var isDestinationViewShowingForMove: Bool = false
    @Published var isRenameButtonDisabled: Bool = true

    var selectedItems: Set<DocumentsExplorerItem> = [] {
        didSet {
            isRenameButtonDisabled = selectedItems.count != 1
        }
    }
    private var visibleURL: URL

    init() {
        let rootURL = URL.homeDirectory
        items = [rootURL: FileManager.default.getDocumentsItems(in: rootURL)]
        visibleURL = rootURL
    }

    func onAppear(url: URL) {
        visibleURL = url
        refresh()
    }

    func createNewDirectory(dirName: String) {
        try? FileManager.default.createDirectory(
            at: visibleURL.appendingPathComponent(dirName),
            withIntermediateDirectories: true,
            attributes: nil
        )
        refresh()
    }

    func createYouTubeFile(videoId: String) {
        let file = YouTubeVideoItem(videoId: videoId)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: visibleURL.appendingPathComponent("\(videoId).youtube"))
        } catch let exception {
            print(exception)
        }
        refresh()
    }

    func rename(item: DocumentsExplorerItem, newName: String) {
        let fromURL = item.url
        let toURL = item.url.deletingLastPathComponent().appendingPathComponent("\(newName).\(fromURL.pathExtension)")
        do {
            try FileManager.default.moveItem(at: fromURL, to: toURL)
            try updateBookmark(with: item, to: toURL)
        } catch let exception {
            // TODO: Show alert
            print(exception)
        }
        refresh()
        isEditing = false
    }

    func moveSelectedItems(to: URL) {
        selectedItems.forEach { item in
            let fromURL = item.url
            let toURL = to.appendingPathComponent(item.nameWithExtension)
            do {
                try FileManager.default.moveItem(at: fromURL, to: toURL)
                try updateBookmark(with: item, to: toURL)
            } catch let exception {
                // TODO: show alert
                print(exception)
            }
        }
        refresh()
        isEditing = false
        isDestinationViewShowingForMove = false
    }

    func copySelectedItems(to: URL) {
        copy(urls: selectedItems.map { $0.url }, to: to)
        isEditing = false
        isDestinationViewShowingForCopy = false
    }

    func copyToVisibleURL(urls: [URL]) {
        copy(urls: urls, to: visibleURL)
    }

    func copy(urls: [URL], to: URL) {
        urls.forEach { url in
            let toURL = to.appendingPathComponent(url.lastPathComponent)
            do {
                try FileManager.default.copyItem(at: url, to: toURL)
            } catch let exception {
                // TODO: show alert
                print(exception)
            }
        }
        refresh()
    }

    func removeSelectedItems() {
        selectedItems.forEach { item in
            do {
                let realm = try Realm()
                try FileManager.default.removeItem(at: item.url)
                let previousBookmarks = realm.objects(BookmarkObject.self).filter("relativePath = '\(URL.relativePathFromHome(url: item.url))'")
                try realm.write {
                    realm.delete(previousBookmarks)
                }
            } catch let exception {
                print(exception)
            }
        }
        refresh()
        isEditing = false
    }

    func refresh() {
        items[visibleURL] = FileManager.default.getDocumentsItems(in: visibleURL)
    }

    private func updateBookmark(with item: DocumentsExplorerItem, to: URL) throws {
        let realm = try Realm()
        try realm.write {
            let previousBookmarks = realm.objects(BookmarkObject.self)
                .filter("relativePath = '\(URL.relativePathFromHome(url: item.url))'")
            previousBookmarks.forEach {
                realm.add(BookmarkObject.copy(previous: $0, relativePath: URL.relativePathFromHome(url: to)))
            }
            realm.delete(previousBookmarks)
        }
    }
}

fileprivate extension FileManager {
    func getDocumentsItems(in url: URL) -> [DocumentsExplorerItem] {
        let files = getFiles(in: url)
        return (
            files.filter { $0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
                + files.filter { !$0.isDir }.sorted { $0.url.lastPathComponent < $1.url.lastPathComponent }
            )
            .map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
    }
}
