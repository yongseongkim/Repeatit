//
//  DocumentsExplorerRenamePopup.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import SwiftUI

struct DocumentsExplorerRenamePopup: View {
    @State var textInput: String
    let positiveButtonTapped: (String) -> ()
    let negativeButtonTapped: () -> ()

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("Rename")
                    .foregroundColor(Color.systemBlack)
                    .padding(EdgeInsets(top: 30, leading: 25, bottom: 0, trailing: 0))
                TextField("Please Enter a new name", text: $textInput)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .padding(EdgeInsets(top: 15, leading: 25, bottom: 30, trailing: 25))
                Divider()
                GeometryReader { containerGeometry in
                    HStack(alignment: .center, spacing: 0) {
                        Button(
                            action: { self.negativeButtonTapped() },
                            label: {
                                Text("Cancel")
                                    .foregroundColor(Color.lushLava)
                            }
                        )
                            .frame(width: containerGeometry.size.width / 2)
                            .frame(minHeight: 0, maxHeight: .infinity)
                        Divider()
                        Button(
                            action: { self.positiveButtonTapped(self.textInput) },
                            label: {
                                Text("Confirm")
                                    .foregroundColor(Color.classicBlue)
                                    .fontWeight(.bold)
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

struct DocumentsExplorerRenamePopup_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerRenamePopup(
            textInput: "first init",
            positiveButtonTapped: { _ in },
            negativeButtonTapped: {}
        )
    }
}
