//
//  AppReducer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/13.
//

import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    // TODO: Make updating documentsItems simple. (There are many use case such as confirmMovingFiles, confirmDeletingFiles)
    switch action {
    case .documentsExplorerAppeared(let url):
        state.currentURL = url
        state.documentItems[url] = environment.fileManager.getDocumentItems(in: url)
    case .editButtonTapped(let isEditing):
        state.isDocumentExplorerEditing = isEditing
        // When editing, hidden floating buttons
        state.isFloatingActionButtonsVisible = !isEditing
        state.isFloatingActionButtonsFolding = true
        state.isActionSheetVisible = isEditing
        // Clear selected items when editing ends.
        state.selectedDocumentItems = []
    case .floatingButtonTapped:
        state.isFloatingActionButtonsFolding = !state.isFloatingActionButtonsFolding
    case .documentItemTappedWhileEditing(let item):
        if let idx = state.selectedDocumentItems.firstIndex(of: item) {
            state.selectedDocumentItems.remove(at: idx)
        } else {
            state.selectedDocumentItems.append(item)
        }
        state.isActionSheetRenameButtonEnabled = state.selectedDocumentItems.count == 1
    case .confirmImportURLs(let urls):
        let currentURL = state.currentURL
        urls.forEach { url in
            let toURL = currentURL.appendingPathComponent(url.lastPathComponent)
            do {
                try environment.fileManager.copyItem(at: url, to: toURL)
            } catch let error {
                // TODO: handle error
                print(error)
            }
        }
        state.documentItems[currentURL] = environment.fileManager.getDocumentItems(in: currentURL)
    case .confirmCreatingNewFolder(let newName):
        do {
            let currentURL = state.currentURL
            try environment.fileManager.createDirectory(
                at: currentURL.appendingPathComponent(newName),
                withIntermediateDirectories: true
            )
            state.documentItems[currentURL] = environment.fileManager.getDocumentItems(in: currentURL)
        } catch let error {
            // TODO: handle error
            print(error)
        }
    case .confirmCreatingYoutube(let youtubeId):
        let currentURL = state.currentURL
        let file = YouTubeItem(videoId: youtubeId)
        do {
            let data = try JSONEncoder().encode(file)
            try data.write(to: state.currentURL.appendingPathComponent("\(youtubeId).youtube"))
            state.documentItems[currentURL] = environment.fileManager.getDocumentItems(in: currentURL)
        } catch let exception {
            print(exception)
        }
    case .confirmRenaming(let newName):
        if let target = state.selectedDocumentItems.first {
            let parentDir = target.url.deletingLastPathComponent()
            let newURL = parentDir.appendingPathComponent(newName).appendingPathExtension(target.pathExtension)
            try? environment.fileManager.moveItem(at: target.url, to: newURL)
            state.documentItems[parentDir] = environment.fileManager.getDocumentItems(in: parentDir)
        }
        state.isDocumentExplorerEditing = false
    case .confirmMovingFiles(let targetURL):
        var fromURLs = Set<URL>()
        state.selectedDocumentItems.forEach {
            try? environment.fileManager.moveItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
            fromURLs.insert($0.url.deletingLastPathComponent())
        }
        fromURLs.forEach { state.documentItems[$0] = environment.fileManager.getDocumentItems(in: $0) }
        state.isDocumentExplorerEditing = false
    case .confirmCopyingFiles(let targetURL):
        state.selectedDocumentItems.forEach {
            try? environment.fileManager.copyItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
        }
        state.isDocumentExplorerEditing = false
    case .confirmDeletingFiles:
        var targetURLs = Set<URL>()
        state.selectedDocumentItems.forEach {
            try? environment.fileManager.removeItem(at: $0.url)
            targetURLs.insert($0.url.deletingLastPathComponent())
        }
        targetURLs.forEach { state.documentItems[$0] = environment.fileManager.getDocumentItems(in: $0) }
        state.isDocumentExplorerEditing = false
    }
    return .none
}
