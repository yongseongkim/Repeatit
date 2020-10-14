//
//  AppState.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import Foundation

struct AppState: Equatable {
    var currentURL: URL
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]
    var isDocumentExplorerEditing: Bool = false
    var isFloatingActionButtonsVisible: Bool = true
    var isFloatingActionButtonsFolding: Bool = true
    var isActionSheetVisible: Bool = false
    var isActionSheetRenameButtonEnabled: Bool = false
}
