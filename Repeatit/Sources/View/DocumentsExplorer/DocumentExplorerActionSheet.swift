//
//  DocumentExplorerActionSheet.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftUI
import ComposableArchitecture

struct DocumentExplorerActionSheet: View {
    let store: Store<AppState, AppAction>

    @State var isDestinationViewShowingForMove: Bool = false
    @State var isDestinationViewShowingForCopy: Bool = false
    @State var isAlertShowingForRemove: Bool = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                // Rename
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture {
                    }
                Spacer()
                // Move
                Image(systemName: "arrow.right.square")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { isDestinationViewShowingForMove = true }
                Spacer()
                // Delete
                Image(systemName: "trash")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { isAlertShowingForRemove = true }
                Spacer()
                // Copy
                Image(systemName: "doc.on.doc")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { isDestinationViewShowingForCopy = true }
            }
            // Show View for moving files.
            .background(
                EmptyView().sheet(
                    isPresented: $isDestinationViewShowingForMove,
                    content: {
                        SelectedDocumentItemsDestinationNavigatorView(
                            store: .init(
                                initialState: .init(
                                    currentURL: URL.homeDirectory,
                                    documentItems: [:],
                                    selectedDocumentItems: viewStore.selectedDocumentItems
                                ),
                                reducer: selectedDocumentItemsDestinationNavigatorReducer,
                                environment: SelectedDocumentItemsDestinationNavigatiorEnvironment()
                            ),
                            onConfirmTapped: {
                                viewStore.send(.confirmMovingFiles($0))
                                isDestinationViewShowingForMove = false
                            },
                            onCancelTapped: { isDestinationViewShowingForMove = false }
                        )
                    }
                )
            )
            // Show View for copying files.
            .background(
                EmptyView().sheet(
                    isPresented: $isDestinationViewShowingForCopy,
                    content: {
                        SelectedDocumentItemsDestinationNavigatorView(
                            store: .init(
                                initialState: .init(
                                    currentURL: URL.homeDirectory,
                                    documentItems: [:],
                                    selectedDocumentItems: viewStore.selectedDocumentItems
                                ),
                                reducer: selectedDocumentItemsDestinationNavigatorReducer,
                                environment: SelectedDocumentItemsDestinationNavigatiorEnvironment()
                            ),
                            onConfirmTapped: {
                                viewStore.send(.confirmCopyingFiles($0))
                                isDestinationViewShowingForCopy = false
                            },
                            onCancelTapped: { isDestinationViewShowingForCopy = false }
                        )
                    }
                )
            )
            // Show Alert for deleting files.
            .alert(
                isPresented: $isAlertShowingForRemove,
                content: {
                    Alert(
                        title: Text("Delete"),
                        message: Text("Are you sure to delete the items?"),
                        primaryButton: .default(Text("Confirm"), action: { viewStore.send(.confirmDeletingFiles) }),
                        secondaryButton: .cancel(Text("Cancel"), action: { self.isAlertShowingForRemove = false })
                    )
                }
            )
        }
        .padding([.leading, .trailing], 25)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

struct DocumentExplorerActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        DocumentExplorerActionSheet(
            store: Store(
                initialState: AppState(
                    currentURL: URL.homeDirectory,
                    documentItems: [URL.homeDirectory: FileManager.default.getDocumentItems(in: URL.homeDirectory)],
                    selectedDocumentItems: []
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
        .previewLayout(.sizeThatFits)
    }
}

struct DocumentsExplorerActionSheet: View {
    @ObservedObject var model: ViewModel
    let listener: Listener?

    var body: some View {
        HStack {
            Image(systemName: "square.and.pencil")
                .resizable()
                .foregroundColor(self.renameButtonColor)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    self.listener?.onRenameButtonTapped?()
                }
                .disabled(self.model.isRenameButtonDisabled)
            Spacer()
            Image(systemName: "arrow.right.square")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    self.listener?.onMoveButtonTapped?()
                }
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { self.listener?.onRemoveButtonTapped?() }
            Spacer()
            Image(systemName: "doc.on.doc")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { self.listener?.onCopyButtonTapped?() }
        }
        .padding([.leading, .trailing], 25)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private var renameButtonColor: Color {
        self.model.isRenameButtonDisabled ? Color.systemBlack.opacity(0.6) : Color.systemBlack
    }
}

extension DocumentsExplorerActionSheet {
    class ViewModel: ObservableObject {
        @Published var isRenameButtonDisabled: Bool = true
    }

    struct Listener {
        let onRenameButtonTapped: (() -> Void)?
        let onMoveButtonTapped: (() -> Void)?
        let onRemoveButtonTapped: (() -> Void)?
        let onCopyButtonTapped: (() -> Void)?
    }
}

struct DocumentsExplorerActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerActionSheet(
            model: .init(),
            listener: nil
        )
            .previewLayout(.sizeThatFits)
    }
}
