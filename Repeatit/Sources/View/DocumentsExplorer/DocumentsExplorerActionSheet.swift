//
//  DocumentsExplorerActionSheet.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftEntryKit
import SwiftUI

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
