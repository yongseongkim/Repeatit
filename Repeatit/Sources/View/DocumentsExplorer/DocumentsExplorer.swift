//
//  DocumentsExplorer.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import SwiftUI

struct DocumentsExplorer: View {
    @EnvironmentObject var store: DocumentsExplorerStore

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                NavigationView {
                    DocumentsExplorerList(url: URL.homeDirectory)
                }
                if !self.store.isEditing {
                    DocumentsExplorerFloatingActionButtons()
                } else {
                    VStack {
                        Spacer()
                        DocumentsExplorerActionSheet()
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .background(Color.systemGray6)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                }
            }
        }
        .background(
            EmptyView().sheet(
                item: .init(get: { self.store.selectedItem }, set: { self.store.selectedItem = $0 }),
                onDismiss: { self.store.selectedItem = nil },
                content: { self.player(item: $0) }
            )
        )
        .background(
            EmptyView().sheet(
                isPresented: .init(get: { self.store.isDestinationViewShowingForCopy }, set: { self.store.isDestinationViewShowingForCopy = $0 }),
                content: {
                NavigationView {
                    DocumentsExplorerDestinationView(
                        url: URL.homeDirectory,
                        selectedFiles: self.store.selectedItems,
                        moveButtonAction: { self.store.copySelectedItems(to: $0) },
                        closeButtonAction: { self.store.isDestinationViewShowingForCopy = false }
                    )
                }
            })
        )
        .background(
            EmptyView().sheet(
                isPresented: .init(get: { self.store.isDestinationViewShowingForMove }, set: { self.store.isDestinationViewShowingForMove = $0 }),
                content: {
                NavigationView {
                    DocumentsExplorerDestinationView(
                        url: URL.homeDirectory,
                        selectedFiles: self.store.selectedItems,
                        moveButtonAction: { self.store.moveSelectedItems(to: $0) },
                        closeButtonAction: { self.store.isDestinationViewShowingForMove = false }
                    )
                }
            })
        )
    }

    private func player(item: DocumentsExplorerItem) -> AnyView {
        if item.isAudioFile {
            return AnyView(AudioPlayerView(item: item.toAudioItem(), audioPlayer: self.store.audioPlayer))
        } else if item.isYouTubeFile {
            return AnyView(YouTubePlayerView(item: item.toYouTubeItem()))
        }
        return AnyView(EmptyView())
    }
}

struct DocumentsExplorer_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorer()
            .environmentObject(DocumentsExplorerStore())
    }
}
