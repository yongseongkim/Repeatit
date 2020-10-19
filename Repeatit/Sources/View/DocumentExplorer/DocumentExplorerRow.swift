//
//  DocumentExplorerRow.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/16.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentExplorerRow: View {
    var document: Document

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: document.imageName)
                    .foregroundColor(.systemBlack)
                Text(document.nameWithExtension)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, 5)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        }
        .contentShape(Rectangle())
    }
}

struct DocumentExplorerSelectableRow: View {
    var document: Document
    var isSelected: Bool
    let onTapGesture: (Document) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: document.imageName)
                    .foregroundColor(.systemBlack)
                Text(document.nameWithExtension)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, 5)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .padding(.leading, 5)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        }
        .contentShape(Rectangle())
        .onTapGesture { self.onTapGesture(self.document) }
    }
}

struct DocumentExplorer_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentExplorerSelectableRow(
                document: Document(
                    url: URL.homeDirectory.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: true
                ),
                isSelected: true,
                onTapGesture: { _ in }
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentExplorerSelectableRow(
                document: Document(
                    url: URL.homeDirectory.appendingPathComponent("name"),
                    isDirectory: false
                ),
                isSelected: true,
                onTapGesture: { _ in }
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentExplorerSelectableRow(
                document: Document(
                    url: URL.homeDirectory.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: false
                ),
                isSelected: false,
                onTapGesture: { _ in }
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentExplorerRow(
                document: Document(
                    url: URL.homeDirectory.appendingPathComponent("name"),
                    isDirectory: true
                )
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentExplorerRow(
                document: Document(
                    url: URL.homeDirectory.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: false
                )
            )
                .previewLayout(.fixed(width: 320, height: 50))
        }
    }
}
