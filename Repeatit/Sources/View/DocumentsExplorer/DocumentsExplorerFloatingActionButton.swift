//
//  DocumentsExplorerFloatingActionButton.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/01.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerFloatingActionButton: View {
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
                    .frame(width: 26, height: 26)
                    .padding(10)
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
            DocumentsExplorerFloatingActionButton(imageSystemName: "play.rectangle.fill", onTapGesture: {})
        }   
    }
}
