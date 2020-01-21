//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct PlayerControlView: View {
    let player: Player

    @State var isPlaying: Bool = false

    var body: some View {
        VStack {
            HStack {
                PlayerMoveControlButtonUI(direction: .backward, seconds: 5)
                    .frame(width: 44, height: 44)
                Spacer()
                PlayerMoveControlButtonUI(direction: .backward, seconds: 1)
                    .frame(width: 44, height: 44)
                Spacer()
                PlayerMoveControlButtonUI(direction: .backward, seconds: 0)
                    .frame(width: 44, height: 44)
                Spacer()
                PlayerMoveControlButtonUI(direction: .forward, seconds: 1)
                    .frame(width: 44, height: 44)
                Spacer()
                PlayerMoveControlButtonUI(direction: .forward, seconds: 5)
                    .frame(width: 44, height: 44)
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 8, trailing: 10))
            HStack {
                Spacer()
                Image(systemName: "backward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                Spacer()
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .onTapGesture {
                        self.player.isPlaying ? self.player.pause() : self.player.resume()
                    }
                Spacer()
                Image(systemName: "forward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                Spacer()
            }
        }
    }
}

struct PlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlView(player: BasicPlayer())
    }
}
