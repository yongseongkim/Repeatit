//
//  TextView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/13.
//

import SwiftUI
import UIKit

struct MultilineTextField: UIViewRepresentable {
    private static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
//        let newSize = view.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
//        if result.wrappedValue != newSize.height {
//            // Call in next render cycle.
//            DispatchQueue.main.async {
//                result.wrappedValue = newSize.height
//            }
//        }
    }

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    let inputAccessaryContent: UIView
    let listener: Listener?

    init<Content: View>(
        text: Binding<String>,
        calculatedHeight: Binding<CGFloat>,
        @ViewBuilder inputAccessaryContent: (() -> Content),
        inputAccessaryContentHeight: CGFloat,
        listener: Listener?
    ) {
        self._text = text
        self._calculatedHeight = calculatedHeight
        let uiView = UIHostingController(rootView: inputAccessaryContent()).apply {
            $0.view.translatesAutoresizingMaskIntoConstraints = false
        }.view!
        uiView.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth, height: inputAccessaryContentHeight)
        self.inputAccessaryContent = uiView
        self.listener = listener
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView().apply {
            $0.isEditable = true
            $0.font = .systemFont(ofSize: 15)
            $0.isSelectable = true
            $0.isUserInteractionEnabled = true
            $0.isScrollEnabled = false
            $0.backgroundColor = .clear
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            $0.inputAccessoryView = inputAccessaryContent
            if listener?.onDone != nil {
                $0.returnKeyType = .done
            }
        }
        textView.text = text
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        MultilineTextField.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, height: $calculatedHeight, listener: listener)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        let listener: MultilineTextField.Listener?

        init(text: Binding<String>, height: Binding<CGFloat>, listener: MultilineTextField.Listener? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.listener = listener
        }

        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            MultilineTextField.recalculateHeight(view: textView, result: calculatedHeight)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            listener?.onEndEditing?(textView.text)
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if let onDone = self.listener?.onDone, text == "\n" {
                textView.resignFirstResponder()
                onDone()
                return false
            }
            return true
        }
    }
}

extension MultilineTextField {
    struct Listener {
        var onEndEditing: ((String) -> Void)?
        var onDone: (() -> Void)?
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        MultilineTextField(
            text: .constant("text"),
            calculatedHeight: .constant(100),
            inputAccessaryContent: { EmptyView() },
            inputAccessaryContentHeight: 44,
            listener: nil
        )
    }
}
