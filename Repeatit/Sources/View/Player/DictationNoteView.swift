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

    let audioPlayer: AudioPlayer
    let url: URL
    let textView = UITextView().apply {
        $0.textContainer.lineFragmentPadding = 0
        $0.textContainerInset = .zero
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textColor = .systemBlack
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
            let keyPath = DictationNote.keyPath(url: parent.url)
            Datastore.shared.dbQueue?.read { db in
                let old = try? DictationNote.fetchOne(db, key: keyPath)
                parent.textView.text = old?.note
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
            do {
                try Datastore.shared.dbQueue?.write { db in
                    if var updated = try? DictationNote.fetchOne(db, key: keyPath) {
                        updated.note = text
                        updated.updatedAt = Date()
                        try updated.update(db)
                    } else {
                        var new = DictationNote(relativePath: keyPath, note: text, createdAt: Date(), updatedAt: Date())
                        new.note = text
                        new.updatedAt = Date()
                        try new.insert(db)
                    }
                    try db.commit()
                }
            } catch let exception {
                print(exception)
            }
        }
    }
}
