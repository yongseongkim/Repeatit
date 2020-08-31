//
//  DocumentsExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                DocumentsExplorerNavigationView(
                    model: .init(
                        fileManager: self.model.fileManager,
                        visibleURL: self.model.visibleURL,
                        isEditing: self.model.isEditing
                    ),
                    listener: .init(
                        onVisibleURLChanged: { self.model.visibleURL = $0 },
                        onEditingTapGesture: { self.model.isEditing = $0 },
                        onFileTapGesture: { self.model.handleSelectedItem($0) }
                    )
                )
                    .onPreferenceChange(
                        DocumentsExplorerSelectedItemsKey.self,
                        perform: { self.model.handleSelectedItemsChanged(items: $0) }
                    )
                if self.model.isEditing {
                    VStack {
                        Spacer()
                        DocumentsExplorerActionSheet(
                            model: self.model.actionSheetViewModel,
                            listener: .init(
                                onRenameButtonTapped: { self.model.handleRenameTapped() },
                                onMoveButtonTapped: { self.model.isDestinationViewShowingForMove = true },
                                onRemoveButtonTapped: { self.model.isAlertShowingForRemove = true },
                                onCopyButtonTapped: { self.model.isDestinationViewShowingForCopy = true }
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
                                self.model.fileManager.copy(urls: urls, to: self.model.visibleURL)
                            },
                            onCreateDirectoryConfirm: { dirName in
                                self.model.fileManager.createNewDirectory(in: self.model.visibleURL, dirName: dirName)
                            },
                            onCreateYouTubeConfirm: { videoId in
                                self.model.fileManager.createYouTubeFile(url: self.model.visibleURL, videoId: videoId, fileName: videoId)
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
                            moveButtonAction: {
                                self.model.fileManager.copy(items: Array(self.model.selectedItems), to: $0)
                                self.model.isEditing = false
                            },
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
                            moveButtonAction: {
                                self.model.fileManager.move(items: Array(self.model.selectedItems), to: $0)
                                self.model.isEditing = false
                            },
                            closeButtonAction: { self.model.isDestinationViewShowingForMove = false }
                        )
                    )
                }
            })
        )
        // Show Alert for deleting files.
        .alert(
            isPresented: .init(get: { self.model.isAlertShowingForRemove }, set: { self.model.isAlertShowingForRemove = $0 }),
            content: {
                Alert(
                    title: Text("Delete"),
                    message: Text("Are you sure to delete the items?"),
                    primaryButton: .default(Text("Confirm"), action: { self.model.handleRemoveTapped() }),
                    secondaryButton: .cancel(Text("Cancel"), action: { self.model.isAlertShowingForRemove = false})
                )
            }
        )
    }
}

extension DocumentsExplorerView {
    class ViewModel: ObservableObject {
        @Published var isDestinationViewShowingForCopy = false
        @Published var isDestinationViewShowingForMove = false
        @Published var isAlertShowingForRemove = false
        @Published var isEditing: Bool = false {
            didSet {
                if !isEditing {
                    self.selectedItems = Set()
                }
            }
        }
        @Published var selectedAudioItem: DocumentsExplorerItem?
        @Published var selectedVideoItem: DocumentsExplorerItem?
        @Published var selectedYouTubeItem: DocumentsExplorerItem?
        @Published var selectedSubtitleItem: DocumentsExplorerItem?

        let appComponent: AppComponent
        let fileManager: DocumentsExplorerFileManager
        let mediaPlayer: MediaPlayer
        let actionSheetViewModel: DocumentsExplorerActionSheet.ViewModel
        var selectedItems: Set<DocumentsExplorerItem> = []
        var visibleURL: URL = URL.homeDirectory

        init(appComponent: AppComponent) {
            self.appComponent = appComponent
            self.fileManager = DocumentsExplorerFileManager()
            self.mediaPlayer = MediaPlayer()
            self.actionSheetViewModel = DocumentsExplorerActionSheet.ViewModel()
        }

        func handleSelectedItemsChanged(items: Set<DocumentsExplorerItem>) {
            self.selectedItems = items
            self.actionSheetViewModel.isRenameButtonDisabled = items.count != 1
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

        func handleRenameTapped() {
            guard let firstItem = selectedItems.first else { return }
            self.showPopup {
                SingleTextFieldPopup(
                    textInput: "",
                    title: "Rename",
                    message: "Please Enter a new name.",
                    placeholder: firstItem.name,
                    positiveButton: ("Confirm", { newName in
                        self.fileManager.rename(item: firstItem, newName: newName)
                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForAction"))
                        self.isEditing = false
                    }),
                    negativeButton: ("Cancel", {
                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForAction"))
                    })
                )
            }
        }

        func handleRemoveTapped() {
            self.fileManager.remove(items: Array(self.selectedItems))
            self.isEditing = false
        }

        private func showPopup<Content: View>(@ViewBuilder builder: @escaping () -> Content) {
            var attributes = EKAttributes()
            attributes.name = "EntryForAction"
            attributes.displayDuration = .infinity
            attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
            attributes.position = .center
            attributes.entranceAnimation = .init(
                scale: .init(from: 0.3, to: 1, duration: 0.1),
                fade: .init(from: 0.8, to: 1, duration: 0.1)
            )
            attributes.exitAnimation = .init(
                scale: .init(from: 1, to: 0.3, duration: 0.1),
                fade: .init(from: 1, to: 0.0, duration: 0.1)
            )
            let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
            let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
            attributes.positionConstraints.keyboardRelation = keyboardRelation
            SwiftEntryKit.display(
                builder: builder,
                using: attributes
            )
        }
    }
}

struct DocumentsExplorer_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerView(model: .init(appComponent: AppComponent()))
    }
}
