//
//  DocumentExplorerListView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerNonSelectableListView<Content: View>: View {
    let documents: [Document]
    let destinationViewBuilder: (_ url: URL) -> Content
    let documentTapped: (Document) -> Void

    var body: some View {
        if documents.isEmpty {
            Text("There is no items")
        } else {
            List(documents, id: \.nameWithExtension) { document in
                if document.isDirectory {
                    NavigationLink(
                        destination: destinationViewBuilder(document.url),
                        label: { DocumentExplorerRow(document: document) }
                    )
                } else {
                    DocumentExplorerRow(document: document)
                        .onTapGesture { documentTapped(document) }
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

//struct DocumentExplorerMultiSelectableListView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            DocumentExplorerMultiSelectableListView(
//                store: .init(
//                    initialState: .init(
//                        currentURL: URL.homeDirectory,
//                        documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
//                        selectedDocuments: [
//                            Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
//                        ]),
//                    reducer: documentExplorerReducer,
//                    environment: DocumentExplorerEnvironment(fileManager: .default)
//                ),
//                documents: [
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
//                ]
//            )
//            .environment(\.colorScheme, .light)
//            .previewLayout(.fixed(width: 320, height: 300))
//            DocumentExplorerMultiSelectableListView(
//                store: .init(
//                    initialState: .init(
//                        currentURL: URL.homeDirectory,
//                        documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
//                        selectedDocuments: [
//                            Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
//                        ]),
//                    reducer: documentExplorerReducer,
//                    environment: DocumentExplorerEnvironment(fileManager: .default)
//                ),
//                documents: [
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
//                ]
//            )
//            .environment(\.colorScheme, .dark)
//            .previewLayout(.fixed(width: 320, height: 300))
//        }
//    }
//}
//
//struct DocumentExplorerListView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            DocumentExplorerListView(
//                documents: [
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
//                ],
//                destinationViewBuilder: { _ in EmptyView() },
//                documentTapped: { _ in }
//            )
//            .environment(\.colorScheme, .light)
//            .previewLayout(.fixed(width: 320, height: 300))
//            DocumentExplorerListView(
//                documents: [
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
//                    Document(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
//                ],
//                destinationViewBuilder: { _ in EmptyView() },
//                documentTapped: { _ in }
//            )
//            .environment(\.colorScheme, .dark)
//            .previewLayout(.fixed(width: 320, height: 300))
//        }
//    }
//}
