//
//  DocumentsPickerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/06.
//

import MobileCoreServices
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    let documentTypes: [UTType]
    let listener: Listener?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let pickerView = UIDocumentPickerViewController(
            forOpeningContentTypes: documentTypes
        )
        pickerView.delegate = context.coordinator
        return pickerView
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
            listener?.onCancel?()
        }
    }
}

extension DocumentPickerView {
    struct Listener {
        let onPickDocuments: (([URL]) -> Void)?
        let onCancel: (() -> Void)?
    }
}

struct DocumentsPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentPickerView(
            documentTypes: [],
            listener: nil
        )
    }
}
