//
//  DocumentsExplorerCreateYouTubePopup.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftUI

struct DocumentsExplorerCreateYouTubePopup: View {
    @State var textInput: String
    let onPositiveButtonTapGesture: (String) -> Void
    let onNegativeButtonTapGesture: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text("YouTube")
                    .foregroundColor(Color.systemBlack)
                    .padding(EdgeInsets(top: 30, leading: 25, bottom: 0, trailing: 25))
                TextField("Please Enter a YouTube link.", text: $textInput)
                    .padding(8)
                    .background(Color(UIColor.systemGray5))
                    .padding(EdgeInsets(top: 15, leading: 25, bottom: 30, trailing: 25))
                Divider()
                GeometryReader { containerGeometry in
                    HStack(alignment: .center, spacing: 0) {
                        Button(
                            action: { self.onNegativeButtonTapGesture() },
                            label: {
                                Text("Cancel")
                                    .foregroundColor(Color.lushLava)
                            }
                        )
                            .frame(width: containerGeometry.size.width / 2)
                            .frame(minHeight: 0, maxHeight: .infinity)
                        Divider()
                        Button(
                            action: { self.onPositiveButtonTapGesture(self.textInput) },
                            label: {
                                Text("Confirm")
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

struct DocumentsExplorerCreateYouTubePopup_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerCreateYouTubePopup(
            textInput: "first init",
            onPositiveButtonTapGesture: { _ in },
            onNegativeButtonTapGesture: {}
        )
    }
}
