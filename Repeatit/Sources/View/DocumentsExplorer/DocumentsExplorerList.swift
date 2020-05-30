//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerList: View {
    @EnvironmentObject var store: DocumentsExplorerStore
    let url: URL

    @ViewBuilder
    var body: some View {
        ZStack {
            if store.isEditing {
                DocumentsExplorerMultiSelectableList(items: self.store.items[url] ?? [])
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading: Button(
                            action: { self.store.isEditing = false },
                            label: {
                                Image(systemName: "xmark")
                                    .padding(12)
                                    .foregroundColor(.systemBlack)
                            }
                        ),
                        trailing: Color.clear
                    )
                    .padding(.bottom, 50)
                    .onPreferenceChange(DocumentsExplorerSelectedItemsKey.self, perform: { self.store.selectedItems = $0 })
            } else {
                List(self.store.items[url] ?? [], id: \.name) { item in
                    if item.isDirectory {
                        NavigationLink(destination: DocumentsExplorerList(url: item.url)) {
                            DocumentsExplorerRow(item: item)
                        }
                    } else {
                        DocumentsExplorerRow(item: item)
                            .onTapGesture { self.store.selectedItem = item }
                    }
                }
                    .lineSpacing(0)
                    .navigationBarItems(
                        leading: Color.clear,
                        trailing: HStack {
                            Button(
                                action: { self.store.isEditing = true },
                                label: {
                                    Image(systemName: "list.bullet")
                                        .padding(12)
                                        .foregroundColor(.systemBlack)
                                }
                            )
                        }
                    )
            }
        }
        .navigationBarTitle(url.lastPathComponent)
        .onAppear { self.store.onAppear(url: self.url) }
    }

    private var renameButtonColor: Color {
        return self.store.isRenameButtonDisabled ? Color.systemGray4 : Color.classicBlue
    }
}

struct DocumentsExplorerList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerList(url: URL.homeDirectory)
                .environmentObject(DocumentsExplorerStore())
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 320, height: 300))
            DocumentsExplorerList(url: URL.homeDirectory)
                .environmentObject(DocumentsExplorerStore())
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 300))
        }
    }
}
