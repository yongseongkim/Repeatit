//
//  PlayerSimpleHeaderView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/07.
//

import SwiftUI

struct PlayerSimpleHeaderView: View {
    let model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(self.model.title)
                    .lineLimit(1)
                    .foregroundColor(.systemBlack)
                    .frame(width: geometry.size.width * 3 / 5 - 25, alignment: .leading)
                Text(self.model.artist)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.systemBlack)
                    .padding(.leading, 10)
                    .frame(width: geometry.size.width * 2 / 5 - 15)
            }
        }
    }
}

extension PlayerSimpleHeaderView {
    struct ViewModel {
        let title: String
        let artist: String
    }
}

struct PlayerSimpleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSimpleHeaderView(
            model: .init(title: "Higher Love", artist: "Kygo, Whitney Houston")
        )
    }
}
