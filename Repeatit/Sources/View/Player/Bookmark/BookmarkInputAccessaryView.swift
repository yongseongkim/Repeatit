//
//  BookmarkInputAccessaryView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import SwiftUI

struct BookmarkInputAccessaryView: View {
    static let height: CGFloat = 50

    @State var isPlaying: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                InputAccessaryTimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { /* move backward by 5 seconds */ }
                InputAccessaryTimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { /* move backward by 1 seconds */ }
                Spacer()
                Button(
                    action: { /* self.model.player.togglePlay()*/ },
                    label: { self.buttonImage }
                )
                    .frame(width: 44, height: 44)
                Spacer()
                InputAccessaryTimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { /* move forward by 5 seconds */ }
                InputAccessaryTimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { /* move forward by 1 seconds */ }
                Spacer()
            }
            Spacer()
            Divider()
                .frame(height: 40)
            Button(
                action: { UIApplication.hideKeyboard() },
                label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundColor(Color.systemBlack)
                }
            )
                .frame(width: 44, height: 44)
        }
    }

    private var buttonImage: some View {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .foregroundColor(Color.systemBlack)
    }
}

struct BookmarkInputAccessaryView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkInputAccessaryView(isPlaying: .init(false))
    }
}
