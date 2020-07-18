//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import SwiftUI

struct RootView: View {
    @Environment(\.appComponent) var appComponent: AppComponent

    var body: some View {
        ZStack {
            DocumentsExplorerView(model: .init(appComponent: appComponent))
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
            .environment(\.appComponent, AppComponent())
    }
}
