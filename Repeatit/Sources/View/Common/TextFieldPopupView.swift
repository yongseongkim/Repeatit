//
//  TextFieldPopupView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/12/02.
//

import SwiftUI

struct TextFieldPopupView: View {
    let model: ViewModel
    let listener: Listener

    @Binding var isPresented: Bool
    @State var textFieldInput: String = ""
    @State var keyboardHeight: CGFloat = 0

    init(
        model: ViewModel,
        listener: Listener,
        isPresented: Binding<Bool>
    ) {
        self.model = model
        self.listener = listener
        self._isPresented = isPresented
    }

    var body: some View {
        ZStack {
            Color.black
                .opacity(isPresented ? 0.6 : 0)
            VStack(spacing: 0) {
                Text(model.title)
                    .font(.system(size: 21))
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .padding(.top, 24)
                    .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                Text(model.message)
                    .font(.system(size: 17))
                    .padding(.top, 7)
                    .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                TextField("", text: $textFieldInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 18))
                    .padding(.all, 7)
                    .background(Color.systemGray5)
                    .cornerRadius(6)
                    .padding(.top, 24)
                    .padding(.bottom, 15)
                HStack(spacing: 12) {
                    Text(model.negativeButton)
                        .font(.system(size: 15))
                        .foregroundColor(Color.systemBlack)
                        .frame(width: 80, height: 40)
                        .background(Color.systemGray5)
                        .cornerRadius(6)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.15)) { isPresented = false }
                            listener.negativeButtonTapped()
                        }
                    Text(model.positiveButton)
                        .font(.system(size: 15))
                        .foregroundColor(Color.systemBlack)
                        .frame(width: 80, height: 40)
                        .background(Color.systemGray5)
                        .cornerRadius(6)
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.15)) { isPresented = false }
                            listener.positiveButtonTapped(textFieldInput)
                        }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                .frame(height: 64)
            }
            .padding([.leading, .trailing], 21)
            .frame(width: 290)
            .background(Color.systemGray6)
            .cornerRadius(10)
            .visibleOrGone(isPresented)
            .transition(.customTransition)
            .onAppear { textFieldInput = model.initialTextFieldText ?? "" }
        }
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
        .edgesIgnoringSafeArea(.all)
    }
}

extension TextFieldPopupView {
    struct ViewModel: Equatable {
        let title: String
        let message: String
        let initialTextFieldText: String?
        let textFieldPlaceholder: String?
        let positiveButton: String
        let negativeButton: String
    }

    struct Listener {
        let positiveButtonTapped: (String) -> Void
        let negativeButtonTapped: () -> Void

        init(
            positiveButtonTapped: ((String) -> Void)? = nil,
            negativeButtonTapped: (() -> Void)? = nil
        ) {
            self.positiveButtonTapped = positiveButtonTapped ?? { _ in }
            self.negativeButtonTapped = negativeButtonTapped ?? { }
        }
    }
}

extension AnyTransition {
    fileprivate static var customTransition: AnyTransition {
        let insertion = AnyTransition.scale(scale: 0.4)
            .animation(
                .spring(response: 0.2, dampingFraction: 0.4, blendDuration: 0)
            )
        let removal = AnyTransition.scale
        return .asymmetric(insertion: insertion, removal: removal)
    }
}

struct TextFieldPopupView_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPopupView(
            model: .init(
                title: "Title",
                message: "message",
                initialTextFieldText: "first commit",
                textFieldPlaceholder: "",
                positiveButton: "Confirm",
                negativeButton: "Cancel"
            ),
            listener: .init(
                positiveButtonTapped: { _ in },
                negativeButtonTapped: {}
            ),
            isPresented: .constant(true)
        )
    }
}
