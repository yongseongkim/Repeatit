//
//  DocumentExplorerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture
import SwiftUI

enum DocumentExplorerAction: Equatable {
    enum AlertAction {
        case confirmTapped
        case cancelTapped
    }

    case setEditing(Bool)
    case refresh
    case didAppear(URL)
    case didTap(Document)
    case toggleEditing
    case toggleDocumentSelection(Document)
    case moveButtonTapped
    case copyButtonTapped
    case deleteButtonTapped

    case confirmImportURLs([URL])
    case deleteAlert(AlertAction)
    // Popup events
    case newFolderConfirmed(String)
    case youtubeConfirmed(String)
    case renameConfirmed(String)

    // Set presntation of sheets
    case setSelectedDocumentsNavigator(isPresented: Bool)

    // Integrate subreducers.
    case selectedDocumentsNavigator(SelectedDocumentsDestinationNavigatorAction)
}

struct DocumentExplorerState: Equatable {
    var visibleURL: URL
    var isEditing: Bool
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]

    var isActionSheetVisible: Bool = false
    var isFloatingButtonsVisible: Bool = true
    var deleteAlert: AlertState<DocumentExplorerAction.AlertAction>?

    // Subreducers
    var selectedDocumentsNavigator: SelectedDocumentsDestinationNavigatiorState?
}

struct DocumentExplorerEnvironment {
    let fileManager: FileManager
}

let documentExplorerReducer = Reducer<DocumentExplorerState, DocumentExplorerAction, DocumentExplorerEnvironment>.combine(
    selectedDocumentsDestinationNavigatorReducer
        .optional(breakpointOnNil: false)
        .pullback(
            state: \.selectedDocumentsNavigator,
            action: /DocumentExplorerAction.selectedDocumentsNavigator,
            environment: { SelectedDocumentsDestinationNavigatiorEnvironment(fileManager: $0.fileManager) }
        ),
    Reducer<DocumentExplorerState, DocumentExplorerAction, DocumentExplorerEnvironment> { state, action, environment in
        switch action {
        case .setEditing(let isEditing):
            state.isEditing = isEditing
            state.selectedDocuments = []
            state.isActionSheetVisible = isEditing
            state.isFloatingButtonsVisible = !isEditing
            return .none
        case .refresh:
            let url = state.visibleURL
            state.documents[url] = environment.fileManager.getDocuments(in: url)
            return .none
        case .didAppear(let url):
            state.visibleURL = url
            return .init(value: .refresh)
        case .didTap:
            return .none
        case .toggleEditing:
            return Effect.init(value: .setEditing(!state.isEditing))
        case .toggleDocumentSelection(let document):
            if let idx = state.selectedDocuments.firstIndex(of: document) {
                state.selectedDocuments.remove(at: idx)
            } else {
                state.selectedDocuments.append(document)
            }
            return .none
        case .moveButtonTapped:
            state.selectedDocumentsNavigator = .init(
                mode: .move,
                currentURL: .homeDirectory,
                documents: state.documents,
                selectedDocuments: state.selectedDocuments
            )
            return .none
        case .copyButtonTapped:
            state.selectedDocumentsNavigator = .init(
                mode: .move,
                currentURL: .homeDirectory,
                documents: state.documents,
                selectedDocuments: state.selectedDocuments
            )
            return .none
        case .deleteButtonTapped:
            state.deleteAlert = .init(
                title: "Delete",
                message: "Are you sure to delete the documents?",
                primaryButton: .default("Confirm", send: .confirmTapped),
                secondaryButton: .cancel()
            )
            return .none
        case .confirmImportURLs(let urls):
            return .none
        case .deleteAlert(let action):
            switch action {
            case .confirmTapped:
                state.selectedDocuments.forEach {
                    try? environment.fileManager.removeItem(at: $0.url)
                }
                return .concatenate(
                    .init(value: .setEditing(false)),
                    .init(value: .refresh)
                )
            case .cancelTapped:
                state.deleteAlert = nil
                return .none
            }
        case .newFolderConfirmed(let newName):
            try? environment.fileManager.createDirectory(at: state.visibleURL.appendingPathComponent(newName), withIntermediateDirectories: true, attributes: nil)
            return .init(value: .refresh)
        case .youtubeConfirmed(let link):
            if let youtubeID = link.parseYouTubeID() {
                let file = YouTubeItem(id: youtubeID)
                do {
                    let data = try JSONEncoder().encode(file)
                    try data.write(to: state.visibleURL.appendingPathComponent("\(youtubeID).youtube"))
                } catch let exception {
                    print(exception)
                }
            }
            return .init(value: .refresh)
        case .renameConfirmed(let newName):
            guard let from = state.selectedDocuments.first?.url else { return .none }
            let ext = from.pathExtension
            let to = from
                .deletingLastPathComponent()
                .appendingPathComponent(newName)
                .appendingPathExtension(ext)
            try? environment.fileManager.moveItem(at: from, to: to)
            return .concatenate(
                .init(value: .setEditing(false)),
                .init(value: .refresh)
            )
        case .setSelectedDocumentsNavigator(let isPresented):
            guard !isPresented else { return .none }
            state.selectedDocumentsNavigator = nil
            return .none
        case .selectedDocumentsNavigator(let action):
            switch action {
            case .destinationViewAppeared:
                return .none
            case .confirmButtonTapped:
                return .none
            case .cancelButtonTapped:
                return .init(value: .setSelectedDocumentsNavigator(isPresented: false))
            case .actionCompleted:
                return .concatenate(
                    .init(value: .setSelectedDocumentsNavigator(isPresented: false)),
                    .init(value: .setEditing(false)),
                    .init(value: .didAppear(state.visibleURL))
                )
            }
        }
    }
)
