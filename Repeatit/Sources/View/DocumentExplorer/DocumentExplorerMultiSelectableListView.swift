//
//  DocumentExplorerMultiSelectableListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/25.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerMultiSelectableListView: View {
    let documents: [Document]
    let selectedDocuments: [Document]
    let documentTapped: (Document) -> Void

    var body: some View {
        if documents.isEmpty {
            Text("There is no items")
        } else {
            List(documents, id: \.nameWithExtension) { document in
                DocumentExplorerSelectableRow(
                    document: document,
                    isSelected: selectedDocuments.contains(document),
                    onTapGesture: { documentTapped($0) }
                )
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
