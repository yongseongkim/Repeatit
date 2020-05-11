//
//  PlayerHeaderView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct PlayerHeaderView: View {
    let model: ViewModel
    
    var body: some View {
        HStack(spacing: 17) {
            Image(uiImage: self.model.artwork)
                .resizable()
                .frame(width: 100, height: 100)
                .background(Color.white)
                .cornerRadius(8)
            VStack(alignment: .leading, spacing: 0) {
                Text(self.model.title)
                    .font(.system(size: 21))
                    .foregroundColor(.systemBlack)
                Text(self.model.artist)
                    .font(.system(size: 17))
                    .foregroundColor(.systemGray)
                    .padding(.top, 7)
            }
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(12)
        .background(Color.systemGray6)
    }
}

extension PlayerHeaderView {
    struct ViewModel {
        let title: String
        let artist: String
        let artwork: UIImage
    }
}

struct PlayerHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerHeaderView(
                model: .init(
                    title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ",
                    artist: "Justin bieber",
                    artwork: UIImage(named: "logo_100pt")!
                )
            )
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 360, height: 350))
            PlayerHeaderView(
                model: .init(
                    title: "Second Emotion(Feat. Travis Scott)",
                    artist: "Justin bieber",
                    artwork: UIImage(named: "logo_100pt")!
                )
            )
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 360, height: 200))
        }
    }
}
