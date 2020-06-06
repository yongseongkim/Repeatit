//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/04.
//

import SwiftUI

struct PlayerControlView: View {
    @EnvironmentObject var store: PlayerStore

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                TimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { self.store.player.moveBackward(by: 5) }
                Spacer()
                TimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { self.store.player.moveBackward(by: 1) }
                Spacer()
            }
            Spacer()
            Image(systemName: self.store.player.isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .foregroundColor(.systemBlack)
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .onTapGesture { self.store.player.togglePlay() }
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                TimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { self.store.player.moveForward(by: 1) }
                Spacer()
                TimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { self.store.player.moveForward(by: 5) }
                Spacer()
            }
            Spacer()
        }
        .padding([.top, .bottom], 10)
        .background(Color.systemWhite)
        .cornerRadius(8)
        .padding(10)
        .background(Color.systemGray6)
    }
}

struct PlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerControlView()
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
            PlayerControlView()
                .environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
