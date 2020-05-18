//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        ZStack {
            DocumentsExplorer(store: DocumentsExplorerStore())
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
