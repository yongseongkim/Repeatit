//
//  DocumentsExplorerEditableList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import SwiftUI

struct DocumentsExplorerSelectedItemsKey: PreferenceKey {
    static var defaultValue: Set<DocumentsExplorerItem> = []

    static func reduce(value: inout Set<DocumentsExplorerItem>, nextValue: () -> Set<DocumentsExplorerItem>) {
        value = nextValue()
    }
}

struct DocumentsExplorerMultiSelectableList: View {
    let items: [DocumentsExplorerItem]
    @State var selectedItems: Set<DocumentsExplorerItem> = []
    
    var body: some View {
        List(self.items, id: \.name) { item in
            DocumentsExplorerSelectableRow(item: item, isSelected: self.selectedItems.contains(item))
                .onTapGesture {
                    if self.selectedItems.contains(item) {
                        self.selectedItems.remove(item)
                    } else {
                        self.selectedItems.insert(item)
                    }
            }
        }
        .preference(key: DocumentsExplorerSelectedItemsKey.self, value: selectedItems)
    }
}

struct DocumentsExplorerEditableList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerMultiSelectableList(
            items: [
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("directory1"), isDirectory: true),
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("directory2"), isDirectory: true),
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("file1"), isDirectory: false),
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("file2"), isDirectory: false),
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("file3"), isDirectory: false),
            ],
            selectedItems: [
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("directory1"), isDirectory: true),
                DocumentsExplorerItem(url: URL.documentsURL.appendingPathComponent("file2"), isDirectory: false)
            ]
        )
    }
}
