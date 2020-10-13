//
//  SingleTextFieldPopup.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftUI

struct SingleTextFieldPopup: View {
    @State var textInput: String = ""
    let title: String
    let message: String
    let positiveButton: (name: String, action: (String) -> Void)
    let negativeButton: (name: String, action: () -> Void)

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .foregroundColor(Color.systemBlack)
                    .padding(EdgeInsets(top: 30, leading: 25, bottom: 0, trailing: 25))
                    .font(.system(size: 19, weight: .semibold))
                Text(message)
                    .foregroundColor(Color.systemBlack)
                    .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
                    .font(.system(size: 15))
                TextField(textInput, text: $textInput)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .padding(EdgeInsets(top: 15, leading: 25, bottom: 30, trailing: 25))
                Divider()
                GeometryReader { containerGeometry in
                    HStack(alignment: .center, spacing: 0) {
                        Button(
                            action: { self.negativeButton.action() },
                            label: {
                                Text(self.negativeButton.name)
                                    .foregroundColor(Color.lushLava)
                            }
                        )
                            .frame(width: containerGeometry.size.width / 2)
                            .frame(minHeight: 0, maxHeight: .infinity)
                        Divider()
                        Button(
                            action: { self.positiveButton.action(self.textInput) },
                            label: {
                                Text(self.positiveButton.name)
                                    .foregroundColor(Color.classicBlue)
                                    .fontWeight(.semibold)
                        }
                        )
                            .frame(width: containerGeometry.size.width / 2)
                            .frame(minHeight: 0, maxHeight: .infinity)
                    }
                }
                .frame(height: 50)
            }
            .frame(width: 290)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(8)
            Spacer()
        }
    }
}

struct SingleTextFieldPopup_Previews: PreviewProvider {
    static var previews: some View {
        SingleTextFieldPopup(
            textInput: "first init",
            title: "YouTube",
            message: "Please Enter a YouTube link.",
            positiveButton: ("Confirm", { _ in }),
            negativeButton: ("Cancel", { })
        )
    }
}
