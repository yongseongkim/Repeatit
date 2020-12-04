//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/04.
//

import ComposableArchitecture
import SwiftUI

struct PlayerControlViewAboveKeyboard: View {
    static let height: CGFloat = 56

    let store: Store<PlayerControlState, PlayerControlAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlSmallButton(direction: .backward, seconds: 5)
                        .onTapGesture { viewStore.send(.moveBackward(by: 5)) }
                    Spacer()
                    TimeControlSmallButton(direction: .backward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveBackward(by: 1)) }
                    Spacer()
                }
                Spacer()
                Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                    .padding(10)
                    .onTapGesture { viewStore.send(.togglePlay) }
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlSmallButton(direction: .forward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveForward(by: 1)) }
                    Spacer()
                    TimeControlSmallButton(direction: .forward, seconds: 5)
                        .onTapGesture { viewStore.send(.moveForward(by: 5)) }
                    Spacer()
                }
                Spacer()
            }
        }
        .frame(height: PlayerControlViewAboveKeyboard.height)
        .background(Color.systemWhite)
    }
}

struct PlayerControlViewAboveKeyboard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerControlViewAboveKeyboard(
                store: .init(
                    initialState: .init(isPlaying: true),
                    reducer: Reducer<PlayerControlState, PlayerControlAction, PlayerControlEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.sizeThatFits)
            PlayerControlViewAboveKeyboard(
                store: .init(
                    initialState: .init(isPlaying: false),
                    reducer: Reducer<PlayerControlState, PlayerControlAction, PlayerControlEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
        }
    }
}

struct PlayerControlView: View {
    let store: Store<PlayerControlState, PlayerControlAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlLargeButton(direction: .backward, seconds: 5)
                        .onTapGesture { viewStore.send(.moveBackward(by: 5)) }
                    Spacer()
                    TimeControlLargeButton(direction: .backward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveBackward(by: 1)) }
                    Spacer()
                }
                Spacer()
                Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .padding(10)
                    .onTapGesture { viewStore.send(.togglePlay) }
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    TimeControlLargeButton(direction: .forward, seconds: 1)
                        .onTapGesture { viewStore.send(.moveForward(by: 1)) }
                    Spacer()
                    TimeControlLargeButton(direction: .forward, seconds: 5)
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
    static var previews: some View {
        Group {
            PlayerControlView(
                store: .init(
                    initialState: .init(isPlaying: true),
                    reducer: Reducer<PlayerControlState, PlayerControlAction, PlayerControlEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.sizeThatFits)
            PlayerControlView(
                store: .init(
                    initialState: .init(isPlaying: false),
                    reducer: Reducer<PlayerControlState, PlayerControlAction, PlayerControlEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.sizeThatFits)
        }
    }
}
