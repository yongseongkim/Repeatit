//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/04.
//

import ComposableArchitecture
import SwiftUI

struct PlayerControlView: View {
    let store: Store<PlayerControlState, PlayerControlAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlButton(direction: .backward, seconds: 5)
                        .onTapGesture { viewStore.send(.moveBackward(by: 5)) }
                    Spacer()
                    TimeControlButton(direction: .backward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveBackward(by: 1)) }
                    Spacer()
                }
                Spacer()
                Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .onTapGesture { viewStore.send(.togglePlay) }
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlButton(direction: .forward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveForward(by: 1)) }
                    Spacer()
                    TimeControlButton(direction: .forward, seconds: 5)
                        .onTapGesture { viewStore.send(.moveForward(by: 5)) }
                    Spacer()
                }
                Spacer()
            }
        }
        .padding([.top, .bottom], 10)
        .background(Color.systemWhite)
        .cornerRadius(8)
        .padding(10)
        .background(Color.systemGray6)
    }
}

struct PlayerControlView_Previews: PreviewProvider {
    struct PlayerControlPreviewID: Hashable {}
    static var previews: some View {
        Group {
            PlayerControlView(
                store: .init(
                    initialState: .init(id: PlayerControlPreviewID()),
                    reducer: .empty,
                    environment: PlayerControlEnvironment(client: MockPlayerControlClient()))
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.sizeThatFits)
            PlayerControlView(
                store: .init(
                    initialState: .init(id: PlayerControlPreviewID()),
                    reducer: .empty,
                    environment: PlayerControlEnvironment(client: MockPlayerControlClient()))
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
