//
//  DocumentsExplorerRow.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/16.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerRow: View {
    var item: DocumentsExplorerItem

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(item.isDirectory ? "folder.fill" : "music.note")
                    .foregroundColor(.systemBlack)
                Text(item.name)
                    .foregroundColor(.systemBlack)
                    .offset(x: 10, y: 0)
                Spacer()
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))

        }
    }
}

struct DocumentsExplorerRow_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerRow(
                item: DocumentsExplorerItem(
                    name: "name",
                    isDirectory: false)
            )
                .previewLayout(.fixed(width: 320, height: 50))
            DocumentsExplorerRow(
                item: DocumentsExplorerItem(
                    name: "name",
                    isDirectory: true)
            )
                .previewLayout(.fixed(width: 320, height: 50))
        }
    }
}
