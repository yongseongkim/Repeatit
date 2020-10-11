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

struct DocumentsExplorerMultiSelectableListView: View {
    let items: [DocumentsExplorerItem]
    @State var selectedItems: Set<DocumentsExplorerItem> = []

    var body: some View {
        List(self.items, id: \.nameWithExtension) { item in
            DocumentsExplorerSelectableRow(
                item: item,
                isSelected: self.selectedItems.contains(item),
                onTapGesture: {
                    if self.selectedItems.contains($0) {
                        self.selectedItems.remove($0)
                    } else {
                        self.selectedItems.insert($0)
                    }
            })
        }
        .lineSpacing(0)
        .listStyle(PlainListStyle())
        .preference(key: DocumentsExplorerSelectedItemsKey.self, value: selectedItems)
    }
}

struct DocumentsExplorerEditableList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerMultiSelectableListView(
            items: [
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("directory1directory1directory1directory1directory1directory1directory1"), isDirectory: true),
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("directory2"), isDirectory: true),
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("file1"), isDirectory: false),
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("file2"), isDirectory: false),
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("file3"), isDirectory: false)
            ],
            selectedItems: [
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("directory1"), isDirectory: true),
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("file2"), isDirectory: false)
            ]
        )
    }
}
