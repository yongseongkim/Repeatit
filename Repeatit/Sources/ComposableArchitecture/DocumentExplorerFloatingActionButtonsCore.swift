//
//  DocumentExplorerFloatingActionButtonsCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/25.
//

import ComposableArchitecture

enum DocumentExplorerFloatingActionButtonsAction: Equatable {
    case toggleCollapsed
}

struct DocumentExplorerFloatingActionButtonsState: Equatable {
    var isCollapsed: Bool = true
}

struct DocumentExplorerFloatingActionButtonsEnvironment {

}

let documentExplorerFloatingActionButtonsReducer = Reducer<
    DocumentExplorerFloatingActionButtonsState,
    DocumentExplorerFloatingActionButtonsAction,
    DocumentExplorerFloatingActionButtonsEnvironment
> { state, action, environment in
    switch action {
    case .toggleCollapsed:
        state.isCollapsed = !state.isCollapsed
        return .none
    }
}
