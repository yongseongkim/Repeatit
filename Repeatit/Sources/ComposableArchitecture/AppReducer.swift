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
        state.documents[url] = environment.fileManager.getDocuments(in: url)
    case .editButtonTapped(let isEditing):
        state.isDocumentExplorerEditing = isEditing
        // When editing, hidden floating buttons
        state.isFloatingActionButtonsVisible = !isEditing
        state.isFloatingActionButtonsFolding = true
        state.isActionSheetVisible = isEditing
        // Clear selected items when editing ends.
        state.selectedDocuments = []
    case .floatingButtonTapped:
        state.isFloatingActionButtonsFolding = !state.isFloatingActionButtonsFolding
    case .documentItemTappedWhileEditing(let item):
        if let idx = state.selectedDocuments.firstIndex(of: item) {
            state.selectedDocuments.remove(at: idx)
        } else {
            state.selectedDocuments.append(item)
        }
        state.isActionSheetRenameButtonEnabled = state.selectedDocuments.count == 1
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
        state.documents[currentURL] = environment.fileManager.getDocuments(in: currentURL)
    case .confirmCreatingNewFolder(let newName):
        do {
            let currentURL = state.currentURL
            try environment.fileManager.createDirectory(
                at: currentURL.appendingPathComponent(newName),
                withIntermediateDirectories: true
            )
            state.documents[currentURL] = environment.fileManager.getDocuments(in: currentURL)
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
            state.documents[currentURL] = environment.fileManager.getDocuments(in: currentURL)
        } catch let exception {
            print(exception)
        }
    case .confirmRenaming(let newName):
        if let target = state.selectedDocuments.first {
            let parentDir = target.url.deletingLastPathComponent()
            let newURL = parentDir.appendingPathComponent(newName).appendingPathExtension(target.pathExtension)
            try? environment.fileManager.moveItem(at: target.url, to: newURL)
            state.documents[parentDir] = environment.fileManager.getDocuments(in: parentDir)
        }
        state.isDocumentExplorerEditing = false
    case .confirmMovingFiles(let targetURL):
        var fromURLs = Set<URL>()
        state.selectedDocuments.forEach {
            try? environment.fileManager.moveItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
            fromURLs.insert($0.url.deletingLastPathComponent())
        }
        fromURLs.forEach { state.documents[$0] = environment.fileManager.getDocuments(in: $0) }
        state.isDocumentExplorerEditing = false
    case .confirmCopyingFiles(let targetURL):
        state.selectedDocuments.forEach {
            try? environment.fileManager.copyItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
        }
        state.isDocumentExplorerEditing = false
    case .confirmDeletingFiles:
        var targetURLs = Set<URL>()
        state.selectedDocuments.forEach {
            try? environment.fileManager.removeItem(at: $0.url)
            targetURLs.insert($0.url.deletingLastPathComponent())
        }
        targetURLs.forEach { state.documents[$0] = environment.fileManager.getDocuments(in: $0) }
        state.isDocumentExplorerEditing = false
    }
    return .none
}
