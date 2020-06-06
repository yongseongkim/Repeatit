//
//  DocumentsPickerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/06.
//

import MobileCoreServices
import SwiftUI

struct DocumentsPickerView: UIViewControllerRepresentable {
    let documentTypes: [String]
    let onPickDocuments: (([URL]) -> Void)
    let onCancelPick: () -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(onPickDocuments: onPickDocuments, onCancelPick: onCancelPick)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPickDocuments: (([URL]) -> Void)
        let onCancelPick: () -> Void

        init(onPickDocuments: @escaping (([URL]) -> Void), onCancelPick: @escaping () -> Void) {
            self.onPickDocuments = onPickDocuments
            self.onCancelPick = onCancelPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPickDocuments(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancelPick()
        }
    }
}

struct DocumentsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsPickerView(
            documentTypes: [(kUTTypeImage as String), (kUTTypeMP3 as String)],
            onPickDocuments:  { _ in },
            onCancelPick: { }
        )
    }
}
