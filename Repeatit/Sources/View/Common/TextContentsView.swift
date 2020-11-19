//
//  TextContentsView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/30.
//

import SwiftUI

struct TextContents: Equatable {
    static func from(document: Document) -> TextContents {
        let contents = (try? String(contentsOf: document.url, encoding: .utf8)) ?? ""
        return .init(
            title: document.url.lastPathComponent,
            contents: contents.isEmpty ? "There is no contents." : contents
        )
    }

    static var empty: TextContents {
        .init(title: "", contents: "There is no contents.")
    }

    let title: String
    let contents: String
}

struct TextContentsView: View {
    let value: TextContents

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(value.title)
                .font(.title)
            Text(value.contents)
            Spacer()
        }
        .padding(15)
        .frame(
            minWidth: 0, maxWidth: .infinity,
            minHeight: 0, maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct TextContentsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextContentsView(
                value: .init(
                    title: "Marchmeelo & Halsey - Be kind.srt",
                    contents: "WEBVTT - Some title\nNOTE\nBekind - Marshmello, Halsey\n2020.05.11\nUniversal Music Group\n\n1\n00:10.000 --> 00:15.000 line:0 position:20% size:60% align:start\nWanna believe\n\n2\n00:20.000 --> 00:25.000 line:63% position:72% align:start\nThat you don't have a bad bone in your body.\n\n3 cue identifier\n00:30.000 --> 00:35.000 position:10%,line-left size:35% align:left\nBut the bruises on your ego make you go wild, wild\n\n00:40.000 --> 00:45.000 position:90% size:35% align:right\nWanna believe\n\n00:50.000 --> 00:55.000\nThat even when you're stone cold\n\nNOTE This is the last line in the file"
                )
            )
        }
    }
}
