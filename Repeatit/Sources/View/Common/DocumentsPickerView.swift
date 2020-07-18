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
    let listener: Listener?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .import)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(listener: listener)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let listener: Listener?

        init(listener: Listener?) {
            self.listener = listener
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            listener?.onPickDocuments?(urls)
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            listener?.onCancelPick?()
        }
    }
}

extension DocumentsPickerView {
    struct Listener {
        let onPickDocuments: (([URL]) -> Void)?
        let onCancelPick: (() -> Void)?
    }
}

struct DocumentsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsPickerView(
            documentTypes: [(kUTTypeImage as String), (kUTTypeMP3 as String)],
            listener: .init(
                onPickDocuments: { _ in },
                onCancelPick: { }
            )
        )
    }
}
