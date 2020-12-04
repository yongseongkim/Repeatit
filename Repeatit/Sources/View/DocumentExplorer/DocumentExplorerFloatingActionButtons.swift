//
//  DocumentExplorerFloatingActionButtons.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerFloatingActionButtons: View {
    static let buttonMargin: CGFloat = 12

    let listener: Listener
    @State var isCollapsed: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            VStack(spacing: 14) {
                Spacer()
                DocumentExplorerFloatingActionButton(
                    imageSystemName: "tray.full",
                    onTapGesture: { listener.importButtonTapped() }
                )
                .opacity(isCollapsed ? 0 : 1)
                .offset(
                    x: 0,
                    y: isCollapsed
                        ? (DocumentExplorerFloatingActionButton.size.height
                            + DocumentExplorerFloatingActionButtons.buttonMargin) * 3 + 5
                        : 0
                )
                DocumentExplorerFloatingActionButton(
                    imageSystemName: "play.rectangle",
                    onTapGesture: { listener.youtubeButtonTapped() }
                )
                .opacity(isCollapsed ? 0 : 1)
                .offset(
                    x: 0,
                    y: isCollapsed
                        ? (DocumentExplorerFloatingActionButton.size.height
                            + DocumentExplorerFloatingActionButtons.buttonMargin) * 2 + 5
                        : 0
                )
                DocumentExplorerFloatingActionButton(
                    imageSystemName: "folder",
                    onTapGesture: { listener.newFolderButtonTapped() }
                )
                .opacity(isCollapsed ? 0 : 1)
                .offset(
                    x: 0,
                    y: isCollapsed
                        ? (DocumentExplorerFloatingActionButton.size.height
                            + DocumentExplorerFloatingActionButtons.buttonMargin) * 1 + 5
                        : 0
                )
                Button(
                    action: {
                        withAnimation(.linear(duration: 0.1)) { isCollapsed.toggle() }
                    },
                    label: {
                        Image(systemName: "plus")
                            .resizable()
                            .foregroundColor(Color.systemBlack)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                            .padding(12)
                            .background(Color.systemGray5)
                            .cornerRadius(28)
                            .shadow(color: Color.black.opacity(0.35), radius: 5)
                            .rotationEffect(isCollapsed ? Angle(degrees: 0) : Angle(degrees: 135))
                    }
                )
            }
        }
    }
}

extension DocumentExplorerFloatingActionButtons {
    struct Listener {
        let importButtonTapped: () -> Void
        let youtubeButtonTapped: () -> Void
        let newFolderButtonTapped: () -> Void
    }
}
