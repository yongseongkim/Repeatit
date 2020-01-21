//
//  PlayerHeaderView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct PlayerHeaderView: View {
    struct ViewModel {
        let title: String
        let artist: String
        let artwork: UIImage
    }

    let model: ViewModel

    var body: some View {
        HStack {
            Image(uiImage: self.model.artwork)
                .resizable()
                .frame(width: 100, height: 100)
                .background(Color.white)
                .padding(10)
            VStack(alignment: .leading) {
                Spacer()
                Text(self.model.title)
                    .layoutPriority(5)
                    .foregroundColor(.systemBlack)
                Spacer()
                Text(self.model.artist)
                    .layoutPriority(1)
                    .foregroundColor(.systemBlack)
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Spacer()
        }
        .frame(height: 100)
    }
}

struct PlayerHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerHeaderView(
            model: .init(
                title: "Second Emotion(Feat. Travis Scott)",
                artist: "Justin bieber", artwork: UIImage(named: "logo_100pt")!
            )
        )
    }
}
