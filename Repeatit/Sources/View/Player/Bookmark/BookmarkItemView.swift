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
        .listRowBackground(Color.systemGray6)
        .background(Color.systemGray6)
        .onTapGesture { self.listener?.onTapGesture?() }
    }
}

extension BookmarkAddItemView {
    struct Listener {
        let onTapGesture: (() -> Void)?
    }
}

struct BookmarkAddItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookmarkAddItemView(listener: nil)
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
            BookmarkAddItemView(listener: nil)
                .environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits)
        }
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
                .onTapGesture {
                    listener?.onTapGesture?(millis)
                }
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                // Invisible Text for expanding text editor.
                Text(text.isEmpty ? "Enter your thoughts." : text)
                    .foregroundColor(Color.systemGray2)
                    .opacity(text.isEmpty ? 0.7 : 0)
                    .font(.system(size: 17))
                    .padding(.all, 8)
                TextEditor(
                    text: .init(
                        get: { text },
                        set: {
                            // There is no way to change return key type.
                            // So prevent entering new line.
                            text = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    )
                )
                .font(.system(size: 17))
                .onChange(of: text) { value in
                    listener?.onTextChange?(millis, text)
                }
            }
            .background(Color.systemGray5)
            .cornerRadius(4)
        }
        .padding(EdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15))
        .listRowBackground(Color.systemGray6)
        .background(Color.systemGray6)
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
        let onTextChange: ((_ millis: Int, _ text: String) -> Void)?
    }
}

struct BookmarkEditItemView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookmarkEditItemView(millis: 10000, listener: nil, text: "bookmark text 1")
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 40))
            BookmarkEditItemView(millis: 20000, listener: nil, text: "bookmark text 2")
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 40))
            BookmarkEditItemView(millis: 40000, listener: nil, text: "bookmark text 3")
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 40))
            BookmarkEditItemView(millis: 80000, listener: nil, text: "bookmark text 4")
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 320, height: 40))
        }
    }
}
