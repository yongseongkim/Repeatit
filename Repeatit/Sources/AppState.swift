//
//  AppState.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import Foundation

struct AppState: Equatable {
    var currentURL: URL
    var documentItems: [URL: [DocumentsExplorerItem]]
    var selectedDocumentItems: [DocumentsExplorerItem]
    var isEditing: Bool = false
}
