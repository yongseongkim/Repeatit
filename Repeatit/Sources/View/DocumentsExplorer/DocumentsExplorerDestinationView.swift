//
//  DocumentsExplorerDestinationView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/03.
//

import SwiftUI

struct DocumentsExplorerDestinationView: View {
    let url: URL
    let selectedFiles: Set<DocumentsExplorerItem>
    let moveButtonAction: (URL) -> Void
    let closeButtonAction: () -> Void
    @State private var items: [DocumentsExplorerItem] = []

    var body: some View {
        GeometryReader { geometry in
            VStack {
                List(self.items, id: \.nameWithExtension) { item in
                    if item.isDirectory && !self.selectedFiles.contains(item) {
                        NavigationLink(destination: DocumentsExplorerDestinationView(url: item.url, selectedFiles: self.selectedFiles, moveButtonAction: self.moveButtonAction, closeButtonAction: self.closeButtonAction)) {
                            DocumentsExplorerRow(item: item)
                        }
                    } else {
                        DocumentsExplorerRow(item: item).opacity(0.6)
                    }
                }
                .onAppear {
                    self.items = FileManager.default.getDocumentsItems(in: self.url)
                }
                Button(
                    action: { self.moveButtonAction(self.url) },
                    label: { Text("Confirm").foregroundColor(Color.white) }
                )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.classicBlue)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitle(url.lastPathComponent)
        .navigationBarItems(
            trailing: Button(
                action: { self.closeButtonAction() },
                label: {
                    Image(systemName: "xmark")
                        .padding(12)
                        .foregroundColor(.systemBlack)
                }
            )
        )
    }
}

struct DocumentsExplorerDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerDestinationView(url: URL.homeDirectory, selectedFiles: [], moveButtonAction: { _ in }, closeButtonAction: {})
    }
}
