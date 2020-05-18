//
//  DocumentsExplorerActionSheet.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerActionSheet: View {
    @ObservedObject var store: DocumentsExplorerStore

    var body: some View {
        HStack {
            Image(systemName: "square.and.pencil")
                .resizable()
                .foregroundColor(self.renameButtonColor)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    guard let itemForRename = self.store.selectedItems.first else { return }
                    var attributes = EKAttributes()
                    attributes.name = "EntryForRename"
                    attributes.displayDuration = .infinity
                    attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
                    attributes.position = .center
                    attributes.entranceAnimation = .init(
                        scale: .init(from: 0.3, to: 1, duration: 0.15),
                        fade: .init(from: 0.8, to: 1, duration: 0.1)
                    )
                    attributes.exitAnimation = .init(
                        scale: .init(from: 1, to: 0.3, duration: 0.15),
                        fade: .init(from: 1, to: 0.0, duration: 0.1)
                    )
                    let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
                    let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                    attributes.positionConstraints.keyboardRelation = keyboardRelation
                    SwiftEntryKit.display(
                        builder: {
                            DocumentsExplorerRenamePopup(
                                textInput: itemForRename.name,
                                onPositiveButtonTapGesture: {
                                    self.store.isEditing = false
                                    self.store.rename(item: itemForRename, newName: $0)
                                    SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename"))
                                },
                                onNegativeButtonTapGesture: { SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename")) }
                            )
                        },
                        using: attributes
                    )
                }
                .disabled(self.store.isRenameButtonDisabled)
            Spacer()
            Image(systemName: "arrow.right.square")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    self.store.isDestinationViewShowingForMove = true
                }
            Spacer()
            Image(systemName: "trash")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    self.store.removeSelectedItems()
                }
            Spacer()
            Image(systemName: "doc.on.doc")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture {
                    self.store.isDestinationViewShowingForCopy = true
                }
        }
        .padding([.leading, .trailing], 25)
        .frame(minWidth: 0, maxWidth: .infinity)
    }

    private var renameButtonColor: Color {
        store.isRenameButtonDisabled ? Color.systemBlack.opacity(0.6) : Color.systemBlack
    }
}

struct DocumentsExplorerActionSheet_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerActionSheet(store: DocumentsExplorerStore())
            .previewLayout(.sizeThatFits)
    }
}
