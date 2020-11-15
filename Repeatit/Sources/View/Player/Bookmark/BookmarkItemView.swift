//
//  BookmarkItemView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/21.
//

import SwiftUI

struct BookmarkAddItemView: View {
    let listener: BookmarkAddItemView.Listener?

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "plus.circle")
            Text("Add Bookmark")
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 44)
        .onTapGesture { self.listener?.onTapGesture?() }
    }
}

extension BookmarkAddItemView {
    struct Listener {
        let onTapGesture: (() -> Void)?
    }
}

struct BookmarkEditItemView: View {
    let millis: Millis
    let listener: BookmarkEditItemView.Listener?

    @State var text: String
    @State private var textFieldHeight: CGFloat = 35

    var body: some View {
        HStack {
            Text(formattedTime)
                .onTapGesture { /* update text */ }
            MultilineTextField(
                text: .init(get: { self.text }, set: { self.text = $0 }),
                calculatedHeight: $textFieldHeight,
                inputAccessaryContent: {
                    // TODO: bind player client
                    BookmarkInputAccessaryView(isPlaying: .init(false))
                },
                inputAccessaryContentHeight: BookmarkInputAccessaryView.height,
                listener: .init(
                    onEndEditing: { _ in /* on end editing */ },
                    onDone: { /* on done */ }
                )
            )
                .frame(height: textFieldHeight)
                .background(Color.systemGray5)
                .cornerRadius(8)
                .padding(.leading, 15)
        }
        .background(Color.systemGray6)
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
    }

    private var formattedTime: String {
        let time = Double(millis) / 1000
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let remainder = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String.init(format: "%02d:%02d.%d", minutes, Int(seconds), remainder)
    }
}

extension BookmarkEditItemView {
    struct Listener {
        let onTapGesture: ((Int) -> Void)?
        let onEndEditing: ((Int, String) -> Void)?
        let onDone: ((Int, String) -> Void)?
    }
}
