//
//  DocumentsExplorerRow.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/16.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerSelectableRow: View {
    var item: DocumentsExplorerItem
    var isSelected: Bool

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: item.imageName)
                    .foregroundColor(.systemBlack)
                Text(item.name)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, 5)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .padding(.leading, 5)
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        }
    }
}

struct DocumentsExplorerRow: View {
    var item: DocumentsExplorerItem

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(systemName: item.imageName)
                    .foregroundColor(.systemBlack)
                Text(item.name)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, 5)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        }
    }
}

struct DocumentsExplorerRow_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerSelectableRow(
                item: DocumentsExplorerItem(
                    url: URL.documentsURL.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: true
                ),
                isSelected: true
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentsExplorerSelectableRow(
                item: DocumentsExplorerItem(
                    url: URL.documentsURL.appendingPathComponent("name"),
                    isDirectory: false
                ),
                isSelected: true
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentsExplorerSelectableRow(
                item: DocumentsExplorerItem(
                    url: URL.documentsURL.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: false
                ),
                isSelected: false
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentsExplorerRow(
                item: DocumentsExplorerItem(
                    url: URL.documentsURL.appendingPathComponent("name"),
                    isDirectory: true
                )
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentsExplorerRow(
                item: DocumentsExplorerItem(
                    url: URL.documentsURL.appendingPathComponent("If file name is too looooooooooooong."),
                    isDirectory: false
                )
            )
                .previewLayout(.fixed(width: 320, height: 50))
        }
    }
}
