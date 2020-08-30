//
//  TextContentsView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/08/30.
//

import SwiftUI

struct TextContentsView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(self.model.title)
                .font(.title)
            Text(self.model.contents)
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

extension TextContentsView {
    class ViewModel: ObservableObject {
        let title: String
        let contents: String

        init(item: DocumentsExplorerItem) {
            self.title = item.url.lastPathComponent
            let contents = (try? String(contentsOf: item.url, encoding: .utf8)) ?? ""
            self.contents = contents.isEmpty ? "There is no contents." : contents
        }

        init(title: String, contents: String) {
            self.title = title
            self.contents = contents.isEmpty ? "There is no contents." : contents
        }
    }
}

struct TextContentsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TextContentsView(
                model: .init(
                    title: "Marchmeelo & Halsey - Be kind.srt",
                    contents: "[al:]\n[al:]\n[al:]\n[al:]\n[al:]\n[al:]\n[al:]\n[al:]\n"
//                    contents: "WEBVTT - Some title\nNOTE\nBekind - Marshmello, Halsey\n2020.05.11\nUniversal Music Group\n\n1\n00:10.000 --> 00:15.000 line:0 position:20% size:60% align:start\nWanna believe\n\n2\n00:20.000 --> 00:25.000 line:63% position:72% align:start\nThat you don't have a bad bone in your body.\n\n3 cue identifier\n00:30.000 --> 00:35.000 position:10%,line-left size:35% align:left\nBut the bruises on your ego make you go wild, wild\n\n00:40.000 --> 00:45.000 position:90% size:35% align:right\nWanna believe\n\n00:50.000 --> 00:55.000\nThat even when you're stone cold\n\nNOTE This is the last line in the file"
                )
            )
        }
    }
}
