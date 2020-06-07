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
            viewBuilder()
        }
        .navigationBarTitle(url.lastPathComponent)
        .onAppear { self.store.onAppear(url: self.url) }
    }

    private var renameButtonColor: Color {
        return self.store.isRenameButtonDisabled ? Color.systemGray4 : Color.classicBlue
    }

    private func viewBuilder() -> AnyView {
        let items = store.getItems(in: url)
        if items.isEmpty {
            return AnyView(
                Text("There is no items.")
            )
        } else {
            if store.isEditing {
                return AnyView(
                    DocumentsExplorerMultiSelectableList(items: self.store.items[url] ?? [])
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(
                            trailing: Button(
                                action: { self.store.isEditing = false },
                                label: {
                                    Image(systemName: "xmark")
                                        .padding(12)
                                        .foregroundColor(.systemBlack)
                                }
                            )
                        )
                        .padding(.bottom, 50)
                        .onPreferenceChange(DocumentsExplorerSelectedItemsKey.self, perform: { self.store.selectedItems = $0 })
                )
            } else {
                return AnyView(
                    List(self.store.items[url] ?? [], id: \.nameWithExtension) { item in
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
                    .navigationBarBackButtonHidden(false)
                    .navigationBarItems(
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
                )
            }
        }
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
