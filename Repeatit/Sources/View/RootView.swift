//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var store: RootStore

    var body: some View {
        ZStack {
            DocumentsExplorer()
                .environmentObject(store.docummentsExplorerStore)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environmentObject(RootStore())
    }
}
