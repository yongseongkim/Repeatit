//
//  InfiniteLoadingView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/30.
//

import SwiftUI

struct InfiniteLoadingView: View {
    @State var isAnimating: Bool = false

    var infiniteAnimation: Animation {
        Animation
            .linear(duration: 2)
            .repeatForever(autoreverses: false)
    }

    var body: some View {
        Image(systemName: "slowmo")
            .rotationEffect(.init(degrees: self.isAnimating ? 360 : 0.0))
            .animation(self.isAnimating ? infiniteAnimation : .default)
            .onAppear { self.isAnimating = true }
            .onDisappear { self.isAnimating = false }
    }
}

struct InfiniteLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        InfiniteLoadingView()
    }
}
