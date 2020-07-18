//
//  DocumentsExplorerNavigationView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/13.
//

import Combine
import Foundation
import SwiftUI

struct DocumentsExplorerNavigationView: View {
    @ObservedObject var model: ViewModel
    let listener: Listener?

    var body: some View {
        NavigationView {
            DocumentsExplorerListView(
                model: .init(
                    fileManager: model.fileManager,
                    url: URL.homeDirectory
                ),
                listener: .init(
                    onAppear: { self.model.visibleURL = $0 },
                    onFileTapGesture: { self.listener?.onFileTapGesture?($0) }
                )
            )
        }
    }
}

extension DocumentsExplorerNavigationView {
    class ViewModel: ObservableObject {
        let fileManager: DocumentsExplorerFileManager
        fileprivate(set) var visibleURL: URL

        init(fileManager: DocumentsExplorerFileManager, visibleURL: URL, listener: Listener? = nil) {
            self.fileManager = fileManager
            self.visibleURL = visibleURL
        }
    }


    struct Listener {
        let onFileTapGesture: ((DocumentsExplorerItem) -> Void)?
    }
}

struct DocumentsExplorerStackView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerNavigationView(
            model: .init(fileManager: DocumentsExplorerFileManager(), visibleURL: URL.homeDirectory),
            listener: .init(onFileTapGesture: nil)
        )
    }
}
