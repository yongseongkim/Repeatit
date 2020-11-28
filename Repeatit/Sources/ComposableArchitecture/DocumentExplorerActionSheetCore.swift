//
//  DocumentExplorerActionSheetCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/24.
//

import ComposableArchitecture

enum DocumentExplorerActionSheetAction: Equatable {
    enum AlertAction {
        case confirmTapped
    }
    case alert(AlertAction)

    case renameButtonTapped
    case moveButtonTapped
    case copyButtonTapped
    case deleteButtonTapped
}

struct DocumentExplorerActionSheetState: Equatable {
    var isRenameButtonEnabled: Bool = false

    var deleteAlert: AlertState<DocumentExplorerActionSheetAction.AlertAction>?
}

struct DocumentExplorerActionSheetEnvironment {

}

let documentExplorerActionSheetReducer = Reducer<
    DocumentExplorerActionSheetState,
    DocumentExplorerActionSheetAction,
    DocumentExplorerActionSheetEnvironment
> { state, action, environment in
    switch action {
    case .alert:
        return .none
    case .renameButtonTapped:
        return .none
    case .moveButtonTapped:
        return .none
    case .copyButtonTapped:
        return .none
    case .deleteButtonTapped:
        state.deleteAlert = .init(
            title: "Delete",
            message: "Are you sure to delete the documents?",
            primaryButton: .default("Confirm", send: .confirmTapped),
            secondaryButton: .cancel()
        )
        return .none
    }
}
