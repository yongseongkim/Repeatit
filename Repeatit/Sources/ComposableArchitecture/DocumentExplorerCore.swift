//
//  DocumentExplorerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture

enum DocumentExplorerAction: Equatable {
    // Integrate other reducers.
    case selectedDocumentsDestinationNavigator(SelectedDocumentsDestinationNavigatorAction)

    // FloatingButtons
    case confirmImportURLs([URL])
    case confirmCreatingNewFolder(String)
    case confirmCreatingYoutube(String)
    // ActionSheet
    case moveButtonTapped
    case copyButtonTapped
    case deleteButtonTapped
    case confirmRenaming(String)
    case deleteCancelButtonTapped
    case deleteConfirmButtonTapped

    case documentExplorerAppeared(url: URL)
    case editButtonTapped(Bool)
    case floatingButtonTapped
    case documentTapped(Document)
    case documentTappedWhileEditing(Document)
    case refreshAndEditingOff
    case setIsEditing(Bool)
    case setSelectedDocumentsDestinationNavigatorSheet(isPresented: Bool)
}

struct DocumentExplorerState: Equatable {
    var currentURL: URL
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]

    var isEditing: Bool = false
    var isFloatingActionButtonsVisible: Bool = true
    var isFloatingActionButtonsFolding: Bool = true
    var isActionSheetVisible: Bool = false
    var isActionSheetRenameButtonEnabled: Bool = false

    var alertForDeleting: AlertState<DocumentExplorerAction>?
    // When dismiss NavigationVIew after pushing some views, a crash happened.
    // When onAppear is called, state should be not nil but is nil.
    // Dismissing the NavigationView, the root view of NavigationView called onAppear same time.
    // So don't make nil after allocated.
    var selectedDocumentsDestinationNavigator: SelectedDocumentsDestinationNavigatiorState?
    var isSelectedDocumentsDestinationNavigatorPresented: Bool = false
}

struct DocumentExplorerEnvironment {
    let fileManager: FileManager
}

let documentExplorerReducer = Reducer<DocumentExplorerState, DocumentExplorerAction, DocumentExplorerEnvironment>.combine(
    selectedDocumentsDestinationNavigatorReducer
        .optional()
        .pullback(
            state: \.selectedDocumentsDestinationNavigator,
            action: /DocumentExplorerAction.selectedDocumentsDestinationNavigator,
            environment: { SelectedDocumentsDestinationNavigatiorEnvironment(fileManager: $0.fileManager) }
        ),
    Reducer<DocumentExplorerState, DocumentExplorerAction, DocumentExplorerEnvironment> { state, action, environment in
        switch action {
        case .selectedDocumentsDestinationNavigator(let action):
            switch action {
            case .cancelButtonTapped:
                return Effect(value: .setSelectedDocumentsDestinationNavigatorSheet(isPresented: false))
            case .actionCompleted:
                return Effect.concatenate(
                    Effect(value: .setSelectedDocumentsDestinationNavigatorSheet(isPresented: false)),
                    Effect(value: .refreshAndEditingOff)
                )
            default:
                return .none
            }
        case .documentExplorerAppeared(let url):
            state.currentURL = url
            state.documents[url] = environment.fileManager.getDocuments(in: url)
            return .none
        case .editButtonTapped(let isEditing):
            return Effect(value: .setIsEditing(isEditing))
        case .floatingButtonTapped:
            state.isFloatingActionButtonsFolding.toggle()
            return .none
        case .documentTapped(let document):
            return .none
        case .documentTappedWhileEditing(let document):
            if let idx = state.selectedDocuments.firstIndex(of: document) {
                state.selectedDocuments.remove(at: idx)
            } else {
                state.selectedDocuments.append(document)
            }
            state.isActionSheetRenameButtonEnabled = state.selectedDocuments.count == 1
            return .none
        case .confirmImportURLs(let urls):
            urls.forEach { url in
                let toURL = state.currentURL.appendingPathComponent(url.lastPathComponent)
                do {
                    try environment.fileManager.copyItem(at: url, to: toURL)
                } catch let error {
                    // TODO: handle error
                    print(error)
                }
            }
            return Effect(value: .refreshAndEditingOff)
        case .confirmCreatingNewFolder(let newName):
            do {
                try environment.fileManager.createDirectory(
                    at: state.currentURL.appendingPathComponent(newName),
                    withIntermediateDirectories: true
                )
            } catch let error {
                // TODO: handle error
                print(error)
            }
            return Effect(value: .refreshAndEditingOff)
        case .confirmCreatingYoutube(let youtubeId):
            let file = YouTubeItem(videoId: youtubeId)
            do {
                let data = try JSONEncoder().encode(file)
                try data.write(to: state.currentURL.appendingPathComponent("\(youtubeId).youtube"))
            } catch let exception {
                print(exception)
            }
            return Effect(value: .refreshAndEditingOff)
        case .moveButtonTapped:
            state.selectedDocumentsDestinationNavigator = SelectedDocumentsDestinationNavigatiorState(
                mode: .move,
                currentURL: URL.homeDirectory,
                documents: state.documents,
                selectedDocuments: state.selectedDocuments
            )
            return Effect(value: .setSelectedDocumentsDestinationNavigatorSheet(isPresented: true))
        case .copyButtonTapped:
            state.selectedDocumentsDestinationNavigator = SelectedDocumentsDestinationNavigatiorState(
                mode: .copy,
                currentURL: URL.homeDirectory,
                documents: state.documents,
                selectedDocuments: state.selectedDocuments
            )
            return Effect(value: .setSelectedDocumentsDestinationNavigatorSheet(isPresented: true))
        case .deleteButtonTapped:
            state.alertForDeleting = .init(
                title: "Delete",
                message: "Are You sure to delete the items?",
                primaryButton: .default("Confirm", send: .deleteConfirmButtonTapped),
                secondaryButton: .cancel()
            )
            return .none
        case .confirmRenaming(let newName):
            if let target = state.selectedDocuments.first {
                let parentDir = target.url.deletingLastPathComponent()
                let newURL = parentDir.appendingPathComponent(newName).appendingPathExtension(target.pathExtension)
                try? environment.fileManager.moveItem(at: target.url, to: newURL)
            }
            return Effect(value: .refreshAndEditingOff)
        case .deleteCancelButtonTapped:
            state.alertForDeleting = nil
            return .none
        case .deleteConfirmButtonTapped:
            state.alertForDeleting = nil
            state.selectedDocuments.forEach { try? environment.fileManager.removeItem(at: $0.url) }
            return Effect(value: .refreshAndEditingOff)
        case .refreshAndEditingOff:
            let currentURL = state.currentURL
            state.documents[currentURL] = environment.fileManager.getDocuments(in: currentURL)
            return Effect(value: .setIsEditing(false))
        case .setIsEditing(let isEditing):
            state.isEditing = isEditing
            // When editing, hidden floating buttons
            state.isFloatingActionButtonsVisible = !isEditing
            state.isFloatingActionButtonsFolding = true
            state.isActionSheetVisible = isEditing
            // Clear selected documents when editing ends.
            state.selectedDocuments = []
            return .none
        case .setSelectedDocumentsDestinationNavigatorSheet(isPresented: let isPresented):
            state.isSelectedDocumentsDestinationNavigatorPresented = isPresented
            return .none
        }
    }
)
.debug()
