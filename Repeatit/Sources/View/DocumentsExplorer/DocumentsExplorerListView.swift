//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import SwiftUI

struct DocumentsExplorerListView: View {
    @ObservedObject var model: ViewModel
    let listener: Listener?

    @ViewBuilder
    var body: some View {
        ZStack {
            if self.model.items.isEmpty {
                Text("There is no items.")
            } else {
                if self.model.isEditing {
                    DocumentsExplorerMultiSelectableListView(items: self.model.items)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(
                            trailing: Button(
                                action: { self.listener?.onEditingTapGesture?(false) },
                                label: {
                                    Image(systemName: "xmark")
                                        .padding(12)
                                        .foregroundColor(.systemBlack)
                                }
                            )
                        )
                        .padding(.bottom, 50)
                } else {
                    List(self.model.items, id: \.nameWithExtension) { item in
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
                                action: { self.listener?.onEditingTapGesture?(true) },
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
        .navigationBarTitle(self.model.url.lastPathComponent)
        .onAppear { self.listener?.onAppear?(self.model.url) }
    }
}

extension DocumentsExplorerListView {
    class ViewModel: ObservableObject {
        @Published var items: [DocumentsExplorerItem]

        let fileManager: DocumentsExplorerFileManager
        let url: URL
        let isEditing: Bool
        var cancellables: [AnyCancellable] = []

        init(fileManager: DocumentsExplorerFileManager, url: URL, isEditing: Bool = false) {
            self.fileManager = fileManager
            self.url = url
            self.items = fileManager.getItems(in: url)
            self.isEditing = isEditing
            fileManager.changesPublisher
                .filter { $0 == url}
                .sink { [weak self] in
                    self?.items = fileManager.getItems(in: $0)
                }
                .store(in: &cancellables)
        }
    }

    struct Listener {
        let onAppear: ((URL) -> Void)?
        let onEditingTapGesture: ((Bool) -> Void)?
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
