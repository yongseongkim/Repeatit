//
//  DocumentsExplorerFloatingActionButton.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/01.
//

import SwiftUI

struct DocumentExplorerFloatingActionButton: View {
    static let size: CGSize = .init(width: 46, height: 46)
    static let padding: CGFloat = 10

    let imageSystemName: String
    let onTapGesture: () -> Void

    var body: some View {
        Button(
            action: onTapGesture,
            label: {
                Image(systemName: imageSystemName)
                    .resizable()
                    .foregroundColor(Color.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: DocumentExplorerFloatingActionButton.size.width
                            - DocumentExplorerFloatingActionButton.padding * 2,
                        height: DocumentExplorerFloatingActionButton.size.height
                            - DocumentExplorerFloatingActionButton.padding * 2
                    )
                    .padding(DocumentExplorerFloatingActionButton.padding)
                    .background(Color.systemGray5)
                    .cornerRadius(23)
                    .shadow(color: Color.black.opacity(0.35), radius: 5)
            }
        )
    }
}

struct DocumentsExplorerFloatingActionButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentExplorerFloatingActionButton(
                imageSystemName: "play.rectangle.fill",
                onTapGesture: {}
            )
            .previewLayout(.fixed(width: 100, height: 100))
        }
    }
}
