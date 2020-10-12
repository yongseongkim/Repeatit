//
//  AppAction.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import Foundation

enum AppAction: Equatable {
    case documentsExplorerAppear(url: URL)
    case editButtonTapped(Bool)
    case floatingButtonTapped
    case documentItemTapWhileEditing(DocumentsExplorerItem)
    case confirmImportURLs([URL])
    case confirmCreatingNewFolder(String)
    case confirmCreatingYoutube(String)
}
