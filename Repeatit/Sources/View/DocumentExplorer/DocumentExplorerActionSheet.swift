//
//  DocumentExplorerActionSheet.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import ComposableArchitecture
import SwiftUI
import SwiftEntryKit

struct DocumentExplorerActionSheet: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                // Rename
                Image(systemName: "square.and.pencil")
                    .resizable()
                    .foregroundColor(
                        viewStore.isActionSheetRenameButtonEnabled ? Color.systemBlack : Color.systemBlack.opacity(0.6)
                    )
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture {
                        showPopup {
                            SingleTextFieldPopup(
                                textInput: viewStore.selectedDocuments.first?.name ?? "",
                                title: "Rename",
                                message: "Please Enter a new name",
                                positiveButton: ("Confirm", {
                                    viewStore.send(.confirmRenaming($0))
                                    hidePopup()
                                }),
                                negativeButton: ("Cancel", {
                                    hidePopup()
                                })
                            )
                        }
                    }
                    .disabled(!viewStore.isActionSheetRenameButtonEnabled)
                Spacer()
                // Move
                Image(systemName: "arrow.right.square")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { viewStore.send(.moveButtonTapped) }
                Spacer()
                // Delete
                Image(systemName: "trash")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { viewStore.send(.deleteButtonTapped) }
                Spacer()
                // Copy
                Image(systemName: "doc.on.doc")
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .onTapGesture { viewStore.send(.copyButtonTapped) }
            }
            .alert(self.store.scope(state: \.alertForDeleting), dismiss: .deleteCancelButtonTapped)
        }
        .padding([.leading, .trailing], 25)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private func showPopup<Content: View>(@ViewBuilder builder: @escaping () -> Content) {
        var attributes = EKAttributes()
        attributes.name = "EntryForActionSheet"
        attributes.displayDuration = .infinity
        attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
        attributes.position = .center
        attributes.entranceAnimation = .init(
            scale: .init(from: 0.3, to: 1, duration: 0.1),
            fade: .init(from: 0.8, to: 1, duration: 0.1)
        )
        attributes.exitAnimation = .init(
            scale: .init(from: 1, to: 0.3, duration: 0.1),
            fade: .init(from: 1, to: 0.0, duration: 0.1)
        )
        let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
        let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
        attributes.positionConstraints.keyboardRelation = keyboardRelation
        SwiftEntryKit.display(
            builder: builder,
            using: attributes
        )
    }

    private func hidePopup() {
        SwiftEntryKit.dismiss(.specific(entryName: "EntryForActionSheet"))
    }
}

struct DocumentExplorerActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        DocumentExplorerActionSheet(
            store: .init(
                initialState: DocumentExplorerState(
                    currentURL: URL.homeDirectory,
                    documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                    selectedDocuments: []
                ),
                reducer: documentExplorerReducer,
                environment: DocumentExplorerEnvironment(fileManager: .default)
            )
        )
        .previewLayout(.sizeThatFits)
    }
}
