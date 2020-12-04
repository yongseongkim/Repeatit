//
//  DocumentExplorerActionSheet.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftUI

struct DocumentExplorerActionSheet: View {
    let isRenameButtonEnabled: Bool
    let listener: Listener

    var body: some View {
        HStack {
            // Rename
            Image(systemName: "square.and.pencil")
                .resizable()
                .foregroundColor(
                    isRenameButtonEnabled ? Color.systemBlack : Color.systemBlack.opacity(0.6)
                )
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { listener.renameButtonTapped() }
                .disabled(!isRenameButtonEnabled)
            Spacer()
            // Move
            Image(systemName: "arrow.right.square")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { listener.moveButtonTapped() }
            Spacer()
            // Copy
            Image(systemName: "doc.on.doc")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { listener.copyButtonTapped() }
            Spacer()
            // Delete
            Image(systemName: "trash")
                .resizable()
                .foregroundColor(Color.systemBlack)
                .frame(width: 24, height: 24)
                .padding(12)
                .onTapGesture { listener.deleteButtonTapped() }
        }
        .padding([.leading, .trailing], 25)
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

extension DocumentExplorerActionSheet {
    struct Listener {
        let renameButtonTapped: () -> Void
        let moveButtonTapped: () -> Void
        let copyButtonTapped: () -> Void
        let deleteButtonTapped: () -> Void
    }
}
