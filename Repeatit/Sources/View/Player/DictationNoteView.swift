//
//  DictationNoteView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/16.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DictationNoteView: UIViewRepresentable {
    typealias UIViewType = UITextView

    let player: Player

    var accessoryView: PlayerControlAccessoryView {
        return PlayerControlAccessoryView(player: player).apply {
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth, height: PlayerControlAccessoryView.height)
        }
    }

    func makeUIView(context: UIViewRepresentableContext<DictationNoteView>) -> UITextView {
        let textView = UITextView()
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.textColor = .systemBlack
        textView.inputAccessoryView = accessoryView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<DictationNoteView>) {
        uiView.delegate = context.coordinator
    }

    func makeCoordinator() -> DictationNoteView.Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DictationNoteView

        init(_ parent: DictationNoteView) {
            self.parent = parent

        }
    }
}
