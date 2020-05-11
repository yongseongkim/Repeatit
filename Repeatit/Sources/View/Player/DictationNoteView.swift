//
//  DictationNoteView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/16.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI
import RealmSwift

struct DictationNoteView: UIViewRepresentable {
    typealias UIViewType = UITextView

    let audioPlayer: AudioPlayer
    let url: URL
    let textView = UITextView().apply {
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .systemBlack
        $0.backgroundColor = .clear
    }

    var accessoryView: PlayerControlAccessoryView {
        return PlayerControlAccessoryView(audioPlayer: audioPlayer).apply {
            $0.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth, height: PlayerControlAccessoryView.height)
        }
    }

    func makeUIView(context: UIViewRepresentableContext<DictationNoteView>) -> UITextView {
        self.textView.inputAccessoryView = accessoryView
        return self.textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<DictationNoteView>) {
        uiView.delegate = context.coordinator
    }

    func makeCoordinator() -> DictationNoteView.Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DictationNoteView

        init(_ parent: DictationNoteView) {
            self.parent = parent
            let realm = try! Realm()
            if let existed = realm.object(ofType: DictationNote.self, forPrimaryKey: DictationNote.keyPath(url: parent.url)) {
                try! realm.write {
                    parent.textView.text = existed.note
                }
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            saveNote(text: textView.text)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            saveNote(text: textView.text)
        }

        private func saveNote(text: String) {
            let keyPath = DictationNote.keyPath(url: parent.url)
            let realm = try! Realm()
            try! realm.write {
                if let updated = realm.object(ofType: DictationNote.self, forPrimaryKey: keyPath) {
                    updated.note = text
                    updated.updatedAt = Date()
                    realm.add(updated, update: .modified)
                } else {
                    let new = DictationNote()
                    new.relativePath = keyPath
                    new.createdAt = Date()
                    new.note = text
                    new.updatedAt = Date()
                    realm.add(new)
                }
            }
        }
    }
}
