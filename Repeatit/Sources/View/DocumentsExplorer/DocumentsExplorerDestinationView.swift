//
//  DocumentsExplorerDestinationView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/03.
//

import SwiftUI

struct DocumentsExplorerDestinationView: View {
    @ObservedObject var model: ViewModel
    let listener: Listener?

    var body: some View {
        GeometryReader { geometry in
            VStack {
                List(self.model.items, id: \.nameWithExtension) { item in
                    if item.isDirectory && !self.model.selectedItems.contains(item) {
                        NavigationLink(
                            destination: DocumentsExplorerDestinationView(
                                model: .init(fileManager: self.model.fileManager, url: item.url),
                                listener: self.listener
                            )
                        ) { DocumentsExplorerRow(item: item) }
                    } else {
                        DocumentsExplorerRow(item: item).opacity(0.6)
                    }
                }
                .listStyle(PlainListStyle())
                Button(
                    action: { self.listener?.moveButtonAction?(self.model.url) },
                    label: { Text("Confirm").foregroundColor(Color.white) }
                )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.classicBlue)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle(self.model.url.lastPathComponent)
        .navigationBarItems(
            trailing: Button(
                action: { self.listener?.closeButtonAction?() },
                label: {
                    Image(systemName: "xmark")
                        .padding(12)
                        .foregroundColor(.systemBlack)
                }
            )
        )
    }
}

extension DocumentsExplorerDestinationView {
    class ViewModel: ObservableObject {
        let fileManager: DocumentsExplorerFileManager
        let url: URL
        let items: [DocumentsExplorerItem]
        let selectedItems: Set<DocumentsExplorerItem>

        init(fileManager: DocumentsExplorerFileManager, url: URL, items: [DocumentsExplorerItem] = [], selectedItems: Set<DocumentsExplorerItem> = [], moveButtonAction: ((URL) -> Void)? = nil, closeButtonAction: (() -> Void)? = nil) {
            self.fileManager = fileManager
            self.url = url
            self.items = items.isEmpty ? fileManager.getItems(in: url) : items
            self.selectedItems = selectedItems
        }
    }

    struct Listener {
        let moveButtonAction: ((URL) -> Void)?
        let closeButtonAction: (() -> Void)?
    }
}

struct DocumentsExplorerDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerDestinationView(
            model: .init(fileManager: DocumentsExplorerFileManager(), url: URL.homeDirectory),
            listener: nil
        )
    }
}
