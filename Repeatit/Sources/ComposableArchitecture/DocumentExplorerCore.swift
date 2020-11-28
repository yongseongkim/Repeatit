//
//  DocumentExplorerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture

enum DocumentExplorerAction: Equatable {
    case setEditing(Bool)
    case didAppear(URL)
    case didTap(Document)
    case toggleDocumentSelection(Document)
    case toggleEditing

    // Integrate subreducers.
    case actionSheet(DocumentExplorerActionSheetAction)
    case floatingActionButtons(DocumentExplorerFloatingActionButtonsAction)
    case selectedDocumentsNavigator(SelectedDocumentsDestinationNavigatorAction)

    // Set presntation of sheets
    case setSelectedDocumentsNavigator(isPresented: Bool)
}

struct DocumentExplorerState: Equatable {
    var visibleURL: URL
    var isEditing: Bool
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]

    // Subreducers
    var actionSheet: DocumentExplorerActionSheetState?
    var floatingActionButtons: DocumentExplorerFloatingActionButtonsState? = .init(isCollapsed: true)
    var selectedDocumentsNavigator: SelectedDocumentsDestinationNavigatiorState?
}

struct DocumentExplorerEnvironment {
    let fileManager: FileManager
}

let documentExplorerReducer = Reducer<DocumentExplorerState, DocumentExplorerAction, DocumentExplorerEnvironment>.combine(
    documentExplorerActionSheetReducer
        .optional()
        .pullback(
            state: \.actionSheet,
            action: /DocumentExplorerAction.actionSheet,
            environment: { _ in DocumentExplorerActionSheetEnvironment() }
        ),
    documentExplorerFloatingActionButtonsReducer
        .optional()
        .pullback(
            state: \.floatingActionButtons,
            action: /DocumentExplorerAction.floatingActionButtons,
            environment: { _ in DocumentExplorerFloatingActionButtonsEnvironment() }
        ),
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
            state.actionSheet = state.isEditing ? .init() : nil
            state.floatingActionButtons = state.isEditing ? nil : .init()
            return .none
        case .didAppear(let url):
            state.visibleURL = url
            state.documents[url] = environment.fileManager.getDocuments(in: url)
            return .none
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
            state.actionSheet = .init(isRenameButtonEnabled: state.selectedDocuments.count == 1)
            return .none
        case .actionSheet(let action):
            switch action {
            case .alert(let action):
                switch action {
                case .confirmTapped:
                    state.selectedDocuments.forEach {
                        try? environment.fileManager.removeItem(at: $0.url)
                    }
                    return .concatenate(
                        .init(value: .setEditing(false)),
                        .init(value: .didAppear(state.visibleURL))
                    )
                }
            case .renameButtonTapped:
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
                return .none
            }
        case .floatingActionButtons:
            return .none
        case .selectedDocumentsNavigator(let action):
            switch action {
            case .actionCompleted:
                return .concatenate(
                    .init(value: .setSelectedDocumentsNavigator(isPresented: false)),
                    .init(value: .setEditing(false)),
                    .init(value: .didAppear(state.visibleURL))
                )
            case .cancelButtonTapped:
                return .init(value: .setSelectedDocumentsNavigator(isPresented: false))
            default:
                return .none
            }
        case .setSelectedDocumentsNavigator(let isPresented):
            guard !isPresented else { return .none }
            state.selectedDocumentsNavigator = nil
            return .none
        }
    }
)
