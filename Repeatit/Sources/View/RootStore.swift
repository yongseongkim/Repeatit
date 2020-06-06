//
//  RootStore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/06.
//

import Foundation
import UIKit

class RootStore: ObservableObject {

    lazy var docummentsExplorerStore: DocumentsExplorerStore = {
        DocumentsExplorerStore()
    }()

    func sceneDidBecomeActive() {
    }

    func sceneWillResignActive() {
    }

    func sceneWillEnterForeground() {
    }

    func sceneDidEnterBackground() {
    }

    func sceneDidOpenURLContexts(_ URLContexts: Set<UIOpenURLContext>) {
        for urlContext in URLContexts {
            let fromURL = urlContext.url
            if fromURL.isFileURL {
                let toURL = URL.homeDirectory.appendingPathComponent(fromURL.lastPathComponent)
                try? FileManager.default.copyItem(at: fromURL, to: toURL)
            }
        }
        docummentsExplorerStore.refresh()
    }
}
