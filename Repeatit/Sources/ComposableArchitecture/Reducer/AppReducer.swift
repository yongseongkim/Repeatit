//
//  AppReducer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/13.
//

import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .documentsExplorerAppear(let url):
        state.currentURL = url
        state.documentItems[url] = environment.fileManager.getDocumentItems(in: url)
    case .editButtonTapped(let isEditing):
        state.isDocumentExplorerEditing = isEditing
        // When editing, hidden floating buttons
        state.isFloatingActionButtonsVisible = !isEditing
        state.isFloatingActionButtonsFolding = true
        // Clear selected items when editing ends.
        state.selectedDocumentItems = []
    case .floatingButtonTapped:
        state.isFloatingActionButtonsFolding = !state.isFloatingActionButtonsFolding
    case .documentItemTapWhileEditing(let item):
        state.selectedDocumentItems.append(item)
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
    }
    return .none
}
