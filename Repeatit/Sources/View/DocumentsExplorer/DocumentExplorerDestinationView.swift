//
//  DocumentExplorerDestinationView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/03.
//

import ComposableArchitecture
import SwiftUI

struct SelectedDocumentItemsDestinationView: View {
    let url: URL
    let selectedDocumentItems: [DocumentsExplorerItem]
    let onConfirmTapped: ((URL) -> Void)
    let onCancelTapped: (() -> Void)

    var body: some View {
        GeometryReader { geometry in
            VStack {
                NavigationView {
                    DocumentExplorerDestinationListView(
                        items: FileManager.default.getDocumentItems(in: url),
                        selectedDocumentItems: selectedDocumentItems
                    )
                }
                Button(
                    action: { onConfirmTapped(url) },
                    label: { Text("Confirm").foregroundColor(Color.white) }
                )
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 50)
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .background(Color.classicBlue)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle(url.lastPathComponent)
            .navigationBarItems(
                trailing: Button(
                    action: { onCancelTapped() },
                    label: {
                        Image(systemName: "xmark")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                    }
                )
            )
        }
    }
}

struct DocumentExplorerDestinationListView: View {
    let items: [DocumentsExplorerItem]
    let selectedDocumentItems: [DocumentsExplorerItem]

    var body: some View {
        List(items, id: \.nameWithExtension) { item in
            if item.isDirectory && !selectedDocumentItems.contains(item) {
                NavigationLink(
                    destination: DocumentExplorerDestinationListView(
                        items: FileManager.default.getDocumentItems(in: item.url),
                        selectedDocumentItems: selectedDocumentItems
                    ),
                    label: { DocumentsExplorerRow(item: item) }
                )
            } else {
                DocumentsExplorerRow(item: item).opacity(0.6)
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct DocumentExplorerDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedDocumentItemsDestinationView(
            url: URL.homeDirectory,
            selectedDocumentItems: [
                DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
            ],
            onConfirmTapped: { _ in },
            onCancelTapped: { }
        )
    }
}
