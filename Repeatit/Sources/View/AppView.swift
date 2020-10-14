//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        GeometryReader { geometry in
            WithViewStore(self.store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        NavigationView {
                            DocumentExplorerView(
                                store: store,
                                url: URL.homeDirectory
                            )
                        }
                        .accentColor(.systemBlack)
                        .padding(.bottom, viewStore.isActionSheetVisible ? 0 : geometry.safeAreaInsets.bottom)
                        DocumentExplorerActionSheet(store: store)
                            .visibleOrGone(viewStore.isActionSheetVisible)
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .background(Color.systemGray6)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    DocumentExplorerFloatingActionButtons(store: store)
                        .visibleOrInvisible(viewStore.isFloatingActionButtonsVisible)
                        .padding(.bottom, 25)
                        .padding(.trailing, 15)
                }
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    currentURL: URL.homeDirectory,
                    documents: [
                        URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)
                    ],
                    selectedDocuments: [],
                    isDocumentExplorerEditing: false,
                    isFloatingActionButtonsVisible: true,
                    isActionSheetVisible: false
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}
