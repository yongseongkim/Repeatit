//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerListView: View {
    @ObservedObject var model: ViewModel
    let listener: Listener?

    var body: some View {
        ZStack {
            contentView
        }
        .navigationBarTitle(self.model.url.lastPathComponent)
        .onAppear { self.listener?.onAppear?(self.model.url) }
    }

    @ViewBuilder
    var contentView: some View {
        let items = model.fileManager.getItems(in: model.url)
        if items.isEmpty {
            Text("There is no items.")
        } else {
            if self.model.isEditing {
                DocumentsExplorerMultiSelectableListView(items: items)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        trailing: Button(
                            action: { self.model.isEditing = false },
                            label: {
                                Image(systemName: "xmark")
                                    .padding(12)
                                    .foregroundColor(.systemBlack)
                            }
                        )
                    )
                    .padding(.bottom, 50)
            } else {
                List(items, id: \.nameWithExtension) { item in
                    if item.isDirectory {
                        NavigationLink(
                            destination:
                                DocumentsExplorerListView(
                                model: .init(
                                    fileManager: self.model.fileManager,
                                    url: item.url
                                ),
                                listener: self.listener
                            ),
                            label: {
                                DocumentsExplorerRow(item: item)
                            }
                        )
                    } else {
                        DocumentsExplorerRow(item: item)
                            .onTapGesture {
                                self.listener?.onFileTapGesture?(item)
                            }
                    }
                }
                .lineSpacing(0)
                .navigationBarBackButtonHidden(false)
                .navigationBarItems(
                    trailing: HStack {
                        Button(
                            action: { self.model.isEditing = true },
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
    }
}

extension DocumentsExplorerListView {
    class ViewModel: ObservableObject {
        let fileManager: DocumentsExplorerFileManager
        let url: URL
        @Published var isEditing: Bool

        init(fileManager: DocumentsExplorerFileManager, url: URL, isEditing: Bool = false) {
            self.fileManager = fileManager
            self.url = url
            self.isEditing = isEditing
        }
    }

    struct Listener {
        let onAppear: ((URL) -> Void)?
        let onFileTapGesture: ((DocumentsExplorerItem) -> Void)?
    }
}

struct DocumentsExplorerList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerListView(model: .init(fileManager: DocumentsExplorerFileManager(), url: URL.homeDirectory), listener: nil)
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 320, height: 300))
            DocumentsExplorerListView(model: .init(fileManager: DocumentsExplorerFileManager(), url: URL.homeDirectory), listener: nil)
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 300))
        }
    }
}
