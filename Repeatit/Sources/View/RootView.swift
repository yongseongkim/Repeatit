//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        ZStack {
            DocumentsExplorer(model: .init())
        }
    }
}

extension RootView {
    class ViewModel: ObservableObject {
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(model: .init())
    }
}
