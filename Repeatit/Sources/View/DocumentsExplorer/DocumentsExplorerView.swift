//
//  DocumentsExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import AVFoundation
import SwiftUI

struct DocumentsExplorerView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DocumentsExplorerNavigationView(
                    model: self.model.navigationViewModel,
                    listener: .init(
                        onEditingTapGesture: { self.model.handleEditingTapGesture(isEditing: $0) },
                        onFileTapGesture: { self.model.handleSelectedItem($0) }
                    )
                )
                    .onPreferenceChange(DocumentsExplorerSelectedItemsKey.self, perform: { self.model.selectedItems = $0 })
                if self.model.isEditing {
                    VStack {
                        Spacer()
                        DocumentsExplorerActionSheet(
                            model: self.model.actionSheetViewModel,
                            listener: .init(
                                onRenameButtonTapped: {},
                                onMoveButtonTapped: {},
                                onRemoveButtonTapped: {},
                                onCopyButtonTapped: {}
                            )
                        )
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .background(Color.systemGray6)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                } else {
                    DocumentsExplorerFloatingActionButtons(
                        model: .init(),
                        listner: .init(
                            onCopyDocumentFiles: { urls in
                                self.model.fileManager.copy(urls: urls, to: self.model.navigationViewModel.visibleURL)
                            },
                            onCreateDirectoryConfirm: { dirName in
                                self.model.fileManager.createNewDirectory(in: self.model.navigationViewModel.visibleURL, dirName: dirName)
                            },
                            onCreateYouTubeConfirm: { videoId in
                                self.model.fileManager.createYouTubeFile(url: self.model.navigationViewModel.visibleURL, videoId: videoId, fileName: videoId)
                            }
                        )
                    )
                }
            }
        }
        .background(
            EmptyView().sheet(
                item: .init(get: { self.model.selectedSubtitleItem }, set: { self.model.selectedSubtitleItem = $0 }),
                onDismiss: { self.model.selectedSubtitleItem = nil },
                content: { TextContentsView(model: .init(item: $0)) }
            )
        )
        // Show players.
        .background(
            EmptyView().sheet(
                item: .init(get: { self.model.selectedAudioItem }, set: { self.model.selectedAudioItem = $0 }),
                onDismiss: { self.model.selectedAudioItem = nil },
                content: { AudioPlayerView(model: .init(player: self.model.mediaPlayer, item: $0)) }
            )
        )
        .background(
            EmptyView().sheet(
                item: .init(get: { self.model.selectedVideoItem }, set: { self.model.selectedVideoItem = $0 }),
                onDismiss: { self.model.selectedVideoItem = nil },
                content: { VideoPlayerView(model: .init(player: self.model.mediaPlayer, item: $0)) }
            )
        )
        .background(
            EmptyView().sheet(
                item: .init(get: { self.model.selectedYouTubeItem }, set: { self.model.selectedYouTubeItem = $0 }),
                onDismiss: { self.model.selectedYouTubeItem = nil },
                content: { YouTubePlayerView(model: .init(player: YouTubePlayer(), item: $0)) }
            )
        )
        // Show View for copying files.
        .background(
            EmptyView().sheet(
                isPresented: .init(get: { self.model.isDestinationViewShowingForCopy }, set: { self.model.isDestinationViewShowingForCopy = $0 }),
                content: {
                NavigationView {
                    DocumentsExplorerDestinationView(
                        model: .init(fileManager: self.model.fileManager, url: URL.homeDirectory),
                        listener: .init(
                            moveButtonAction: { self.model.fileManager.copy(items: Array(self.model.selectedItems), to: $0) },
                            closeButtonAction: { self.model.isDestinationViewShowingForMove = false }
                        )
                    )
                }
            })
        )
        // Show View for moving files.
        .background(
            EmptyView().sheet(
                isPresented: .init(get: { self.model.isDestinationViewShowingForMove }, set: { self.model.isDestinationViewShowingForMove = $0 }),
                content: {
                NavigationView {
                    DocumentsExplorerDestinationView(
                        model: .init(fileManager: self.model.fileManager, url: URL.homeDirectory),
                        listener: .init(
                            moveButtonAction: { self.model.fileManager.move(items: Array(self.model.selectedItems), to: $0) },
                            closeButtonAction: { self.model.isDestinationViewShowingForMove = false }
                        )
                    )
                }
            })
        )
    }
}

extension DocumentsExplorerView {
    class ViewModel: ObservableObject {
        let appComponent: AppComponent
        let fileManager: DocumentsExplorerFileManager
        let mediaPlayer: MediaPlayer
        let navigationViewModel: DocumentsExplorerNavigationView.ViewModel
        let actionSheetViewModel: DocumentsExplorerActionSheet.ViewModel

        @Published var isDestinationViewShowingForCopy = false
        @Published var isDestinationViewShowingForMove = false
        @Published var isEditing: Bool = false
        @Published var selectedAudioItem: DocumentsExplorerItem?
        @Published var selectedVideoItem: DocumentsExplorerItem?
        @Published var selectedYouTubeItem: DocumentsExplorerItem?
        @Published var selectedSubtitleItem: DocumentsExplorerItem?
        var selectedItems: Set<DocumentsExplorerItem> = []

        init(appComponent: AppComponent) {
            self.appComponent = appComponent
            self.fileManager = DocumentsExplorerFileManager()
            self.mediaPlayer = MediaPlayer()
            self.navigationViewModel = DocumentsExplorerNavigationView.ViewModel(
                fileManager: self.fileManager,
                visibleURL: URL.homeDirectory
            )
            self.actionSheetViewModel = DocumentsExplorerActionSheet.ViewModel()
        }

        func handleSelectedItem(_ item: DocumentsExplorerItem) {
            if item.isAudioFile {
                selectedAudioItem = item
            } else if item.isVideoFile {
                selectedVideoItem = item
            } else if item.isYouTubeFile {
                selectedYouTubeItem = item
            } else if item.isSupportedSubtitleFile {
                selectedSubtitleItem = item
            }
        }

        func handleEditingTapGesture(isEditing: Bool) {
            self.isEditing = isEditing
            self.navigationViewModel.isEditing = isEditing
        }
    }
}

struct DocumentsExplorer_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerView(model: .init(appComponent: AppComponent()))
    }
}
