//
//  DocumentExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import ComposableArchitecture
import SwiftUI
import UniformTypeIdentifiers

struct DocumentExplorerView: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    @State var isDocumentPickerPresented: Bool = false
    @State var isNewFolderPopupPresented: Bool = false
    @State var isYouTubePopupPresented: Bool = false
    @State var isRenamePopupPresented: Bool = false

    var body: some View {
        return GeometryReader { geometry in
            WithViewStore(store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        DocumentExplorerNavigationView(store: store)
                            .padding(
                                .bottom,
                                viewStore.isActionSheetVisible ? 0 : geometry.safeAreaInsets.bottom
                            )
                        DocumentExplorerActionSheet(
                            isRenameButtonEnabled: viewStore.selectedDocuments.count == 1,
                            listener: .init(
                                renameButtonTapped: {
                                    withAnimation(.easeIn(duration: 0.15)) {
                                        isRenamePopupPresented = true
                                    }
                                },
                                moveButtonTapped: { viewStore.send(.moveButtonTapped) },
                                copyButtonTapped: { viewStore.send(.copyButtonTapped) },
                                deleteButtonTapped: { viewStore.send(.deleteButtonTapped) }
                            )
                        )
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .background(Color.systemGray6)
                        .visibleOrGone(viewStore.isActionSheetVisible)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    DocumentExplorerFloatingActionButtons(
                        listener: .init(
                            importButtonTapped: { isDocumentPickerPresented = true },
                            youtubeButtonTapped: {
                                withAnimation(.easeIn(duration: 0.15)) {
                                    isYouTubePopupPresented = true
                                }
                            },
                            newFolderButtonTapped: {
                                withAnimation(.easeIn(duration: 0.15)) {
                                    isNewFolderPopupPresented = true
                                }
                            }
                        )
                    )
                    .padding(.bottom, 25)
                    .padding(.trailing, 15)
                    .visibleOrInvisible(viewStore.isFloatingButtonsVisible)
                    textFieldPopupViews
                }
                .background(
                    EmptyView().sheet(
                        isPresented: viewStore.binding(
                            get: { $0.selectedDocumentsNavigator != nil },
                            send: DocumentExplorerAction.setSelectedDocumentsNavigator(isPresented:)
                        ),
                        content: {
                            IfLetStore(
                                store.scope(
                                    state: { $0.selectedDocumentsNavigator },
                                    action: DocumentExplorerAction.selectedDocumentsNavigator
                                )
                            ) { store in
                                SelectedDocumentsDestinationNavigatorView(store: store)
                            }
                        }
                    )
                )
                .background(
                    EmptyView()
                        .sheet(
                            isPresented: $isDocumentPickerPresented,
                            content: {
                                DocumentPickerView(
                                    documentTypes: DocumentExplorerView.documentTypes,
                                    listener: .init(
                                        onPickDocuments: { viewStore.send(.confirmImportURLs($0)) },
                                        onCancel: { isDocumentPickerPresented = false }
                                    )
                                )
                            }
                        )
                )
                .alert(
                    store.scope(
                        state: { $0.deleteAlert },
                        action: DocumentExplorerAction.deleteAlert
                    ),
                    dismiss: .cancelTapped
                )
            }
        }
    }

    var textFieldPopupViews: some View {
        WithViewStore(store) { viewStore in
            Group {
                TextFieldPopupView(
                    model: .init(
                        title: "NewFolder",
                        message: "Please enter new folder name.",
                        initialTextFieldText: nil,
                        textFieldPlaceholder: "New folder name",
                        positiveButton: "Confirm",
                        negativeButton: "Cancel"
                    ),
                    listener: .init(
                        positiveButtonTapped: { viewStore.send(.newFolderConfirmed($0)) }
                    ),
                    isPresented: $isNewFolderPopupPresented
                )
                TextFieldPopupView(
                    model: .init(
                        title: "YouTube",
                        message: "Please enter a youtube link.",
                        initialTextFieldText: nil,
                        textFieldPlaceholder: "ex) https://youtu.be/aDyzBr5ibQE",
                        positiveButton: "Confirm",
                        negativeButton: "Cancel"
                    ),
                    listener: .init(
                        positiveButtonTapped: { viewStore.send(.youtubeConfirmed($0)) }
                    ),
                    isPresented: $isYouTubePopupPresented
                )
                TextFieldPopupView(
                    model: .init(
                        title: "Rename",
                        message: "Please enter new name to rename.",
                        initialTextFieldText: viewStore.selectedDocuments.first?.name,
                        textFieldPlaceholder: nil,
                        positiveButton: "Confirm",
                        negativeButton: "Cancel"
                    ),
                    listener: .init(
                        positiveButtonTapped: { viewStore.send(.renameConfirmed($0)) }
                    ),
                    isPresented: $isRenamePopupPresented
                )
            }
        }
    }
}

extension DocumentExplorerView {
    static let documentTypes = [
        UTType.image,
        UTType.mp3,
        UTType.video,
        UTType.mpeg4Movie,
        UTType.movie
    ]
}
