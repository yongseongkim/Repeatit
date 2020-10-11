//
//  AppAction.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import Foundation

enum AppAction: Equatable {
    case documentsExplorerAppear(url: URL)
    case editButtonTap(Bool)
    case documentItemTapWhileEditing(DocumentsExplorerItem)
}
