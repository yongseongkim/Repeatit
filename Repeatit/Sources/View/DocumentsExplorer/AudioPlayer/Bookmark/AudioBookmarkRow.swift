//
//  AudioBookmarkRow.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import SwiftUI

struct AudioBookmarkRow: View {
    let audioPlayer: AudioPlayer
    let bookmark: AudioBookmark
    @Binding var text: String
    @State private var textFieldHeight: CGFloat = 35

    @ViewBuilder
    var body: some View {
        HStack {
            Text(formattedTime)
            MultilineTextField(
                text: $text,
                calculatedHeight: $textFieldHeight,
                inputAccessaryContent: { AudioBookmarkInputAccessaryView(model: .init(audioPlayer: self.audioPlayer)) },
                inputAccessaryContentHeight: AudioBookmarkInputAccessaryView.height,
                onDone: nil
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
        let time = Double(bookmark.startMillis) / 1000
//        let hour = Int(time / 3600)
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let remainder = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
//        return String.init(format: "%02d:%02d:%02d.%d", hour, minutes, Int(seconds), remainder)
        return String.init(format: "%02d:%02d.%d", minutes, Int(seconds), remainder)
    }
}

struct AudioBookmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        AudioBookmarkRow(
            audioPlayer: BasicAudioPlayer(),
            bookmark: AudioBookmark(),
            text: .constant("bookmark row text")
        )
            .previewLayout(.sizeThatFits)
    }
}
