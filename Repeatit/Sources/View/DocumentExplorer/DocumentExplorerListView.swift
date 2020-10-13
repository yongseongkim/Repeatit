//
//  DocumentExplorerListView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerMultiSelectableListView: View {
    let store: Store<AppState, AppAction>
    let items: [Document]

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List(items, id: \.nameWithExtension) { item in
                DocumentExplorerSelectableRow(
                    item: item,
                    isSelected: viewStore.selectedDocumentItems.contains(item),
                    onTapGesture: { viewStore.send(.documentItemTappedWhileEditing($0)) }
                )
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct DocumentExplorerListView<Content: View>: View {
    let items: [Document]
    let destinationViewBuilder: (_ url: URL) -> Content

    var body: some View {
        List(items, id: \.nameWithExtension) { item in
            if item.isDirectory {
                NavigationLink(
                    destination: destinationViewBuilder(item.url),
                    label: { DocumentExplorerRow(item: item) }
                )
            } else {
                DocumentExplorerRow(item: item)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct DocumentExplorerMultiSelectableListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentExplorerMultiSelectableListView(
                store: Store(
                    initialState: AppState(
                        currentURL: URL.homeDirectory,
                        documentItems: [URL.homeDirectory: FileManager.default.getDocumentItems(in: URL.homeDirectory)],
                        selectedDocumentItems: [
                            Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
                        ]
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                ),
                items: [
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
                ]
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.fixed(width: 320, height: 300))
            DocumentExplorerMultiSelectableListView(
                store: Store(
                    initialState: AppState(
                        currentURL: URL.homeDirectory,
                        documentItems: [URL.homeDirectory: FileManager.default.getDocumentItems(in: URL.homeDirectory)],
                        selectedDocumentItems: [
                            Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
                        ]
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                ),
                items: [
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
                ]
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 320, height: 300))
        }
    }
}

struct DocumentExplorerListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentExplorerListView(
                items: [
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
                ],
                destinationViewBuilder: { _ in EmptyView() }
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.fixed(width: 320, height: 300))
            DocumentExplorerListView(
                items: [
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
                ],
                destinationViewBuilder: { _ in EmptyView() }
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 320, height: 300))
        }
    }
}
