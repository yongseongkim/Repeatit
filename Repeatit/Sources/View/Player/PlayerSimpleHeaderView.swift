//
//  PlayerSimpleHeaderView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/07.
//

import SwiftUI

struct PlayerSimpleHeaderView: View {
    struct ViewModel {
        let title: String
        let artist: String
    }

    let model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            HStack {
                Text(self.model.title)
                    .lineLimit(1)
                    .foregroundColor(.systemBlack)
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 10))
                    .frame(width: geometry.size.width * 3 / 5 - 25, alignment: .leading)
                Text(self.model.artist)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.systemBlack)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 15))
                    .frame(width: geometry.size.width * 2 / 5 - 15)
            }
        }
    }
}

struct PlayerSimpleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerSimpleHeaderView(
            model: .init(title: "Higher Love", artist: "Kygo, Whitney Houston")
        )
    }
}