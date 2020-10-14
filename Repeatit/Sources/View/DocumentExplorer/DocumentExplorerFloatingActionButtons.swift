//
//  DocumentExplorerFloatingActionButtons.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import ComposableArchitecture
import SwiftEntryKit
import SwiftUI
import UniformTypeIdentifiers

struct DocumentExplorerFloatingActionButtons: View {
    let store: Store<AppState, AppAction>
    let documentTypes = [
        UTType.image,
        UTType.mp3,
        UTType.video,
        UTType.mpeg4Movie,
        UTType.movie
    ]
    @State var isDocumentPickerViewShowing: Bool = false

    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 14) {
                    Spacer()
                    // size + space + (`+` button size - current button size)
                    DocumentExplorerFloatingActionButton(
                        // TODO: update image
                        imageSystemName: "tray.full",
                        onTapGesture: { self.isDocumentPickerViewShowing = true }
                    )
                    .sheet(
                        isPresented: self.$isDocumentPickerViewShowing,
                        content: {
                            DocumentPickerView(
                                documentTypes: documentTypes,
                                listener: .init(
                                    onPickDocuments: { viewStore.send(.confirmImportURLs($0)) },
                                    onCancel: { self.isDocumentPickerViewShowing = false }
                                )
                            )
                        }
                    )
                    .opacity(viewStore.isFloatingActionButtonsFolding ? 0 : 1)
                    .offset(x: 0, y: viewStore.isFloatingActionButtonsFolding ? (46 + 14) * 3 + 5 : 0)
                    DocumentExplorerFloatingActionButton(
                        imageSystemName: "play.rectangle",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    textInput: "ex) https://youtu.be/929plYk1lDc",
                                    title: "YouTube",
                                    message: "Please Enter a YouTube link.",
                                    positiveButton: ("Confirm", {
                                        if let youtubeId = $0.getYouTubeId() {
                                            viewStore.send(.confirmCreatingYoutube(youtubeId))
                                        }
                                        hidePopup()
                                    }),
                                    negativeButton: ("Cancel", { hidePopup() })
                                )
                            }
                        }
                    )
                    .opacity(viewStore.isFloatingActionButtonsFolding ? 0 : 1)
                    .offset(x: 0, y: viewStore.isFloatingActionButtonsFolding ? (46 + 14) * 2 + 5 : 0)
                    DocumentExplorerFloatingActionButton(
                        imageSystemName: "folder",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    title: "Directory",
                                    message: "Please Enter a new directory name.",
                                    positiveButton: ("Confirm", {
                                        viewStore.send(.confirmCreatingNewFolder($0))
                                        hidePopup()
                                    }),
                                    negativeButton: ("Cancel", { hidePopup() })
                                )
                            }
                        }
                    )
                    .opacity(viewStore.isFloatingActionButtonsFolding ? 0 : 1)
                    .offset(x: 0, y: viewStore.isFloatingActionButtonsFolding ? 46 + 14 + 5 : 0)
                    // width: 56, height: 56
                    Button(
                        action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                viewStore.send(.floatingButtonTapped)
                            }
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
                                .rotationEffect(viewStore.isFloatingActionButtonsFolding ? Angle(degrees: 0) : Angle(degrees: 135))
                        }
                    )
                }
            }
        }
    }

    private func showPopup<Content: View>(@ViewBuilder builder: @escaping () -> Content) {
        var attributes = EKAttributes()
        attributes.name = "EntryForFloatingActionButtons"
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

    private func hidePopup() {
        SwiftEntryKit.dismiss(.specific(entryName: "EntryForFloatingActionButtons"))
    }
}

struct DocumentExplorerFloatingActionButton_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentExplorerFloatingActionButtons(
                store: Store(
                    initialState: AppState(
                        currentURL: URL.homeDirectory,
                        documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                        selectedDocuments: []
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                )
            )
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 250, height: 320))

            DocumentExplorerFloatingActionButtons(
                store: Store(
                    initialState: AppState(
                        currentURL: URL.homeDirectory,
                        documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                        selectedDocuments: []
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                )
            )
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 250, height: 320))
        }
    }
}
