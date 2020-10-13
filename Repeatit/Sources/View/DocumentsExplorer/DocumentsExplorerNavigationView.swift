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
            Text("")
        }
    }
}

extension DocumentsExplorerNavigationView {
    class ViewModel: ObservableObject {
        let fileManager: DocumentsExplorerFileManager
        fileprivate(set) var visibleURL: URL
        let isEditing: Bool

        init(fileManager: DocumentsExplorerFileManager, visibleURL: URL, isEditing: Bool = false, listener: Listener? = nil) {
            self.fileManager = fileManager
            self.visibleURL = visibleURL
            self.isEditing = isEditing
        }
    }

    struct Listener {
        let onVisibleURLChanged: ((URL) -> Void)?
        let onEditingTapGesture: ((Bool) -> Void)?
        let onFileTapGesture: ((DocumentsExplorerItem) -> Void)?
    }
}

struct DocumentsExplorerStackView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerNavigationView(
            model: .init(fileManager: DocumentsExplorerFileManager(), visibleURL: URL.homeDirectory),
            listener: .init(onVisibleURLChanged: nil, onEditingTapGesture: nil, onFileTapGesture: nil)
        )
    }
}
