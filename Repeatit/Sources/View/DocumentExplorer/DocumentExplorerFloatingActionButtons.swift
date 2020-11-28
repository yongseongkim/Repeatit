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
    let store: Store<DocumentExplorerFloatingActionButtonsState, DocumentExplorerFloatingActionButtonsAction>
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
                                    onPickDocuments: { _ in /* viewStore.send(.confirmImportURLs($0)) */ },
                                    onCancel: { self.isDocumentPickerViewShowing = false }
                                )
                            )
                        }
                    )
                    .opacity(viewStore.isCollapsed ? 0 : 1)
                    .offset(x: 0, y: viewStore.isCollapsed ? (46 + 14) * 3 + 5 : 0)
                    DocumentExplorerFloatingActionButton(
                        imageSystemName: "play.rectangle",
                        onTapGesture: {
//                            self.showPopup {
//                                SingleTextFieldPopup(
//                                    title: "YouTube",
//                                    message: "Please Enter a YouTube link.\nex) https://youtu.be/929plYk1lDc",
//                                    positiveButton: ("Confirm", {
//                                        if let id = $0.parseYouTubeID() {
//                                            viewStore.send(.confirmCreatingYoutube(id))
//                                        }
//                                        hidePopup()
//                                    }),
//                                    negativeButton: ("Cancel", { hidePopup() })
//                                )
//                            }
                        }
                    )
                    .opacity(viewStore.isCollapsed ? 0 : 1)
                    .offset(x: 0, y: viewStore.isCollapsed ? (46 + 14) * 2 + 5 : 0)
                    DocumentExplorerFloatingActionButton(
                        imageSystemName: "folder",
                        onTapGesture: {
//                            self.showPopup {
//                                SingleTextFieldPopup(
//                                    title: "Directory",
//                                    message: "Please Enter a new directory name.",
//                                    positiveButton: ("Confirm", {
//                                        viewStore.send(.confirmCreatingNewFolder($0))
//                                        hidePopup()
//                                    }),
//                                    negativeButton: ("Cancel", { hidePopup() })
//                                )
//                            }
                        }
                    )
                    .opacity(viewStore.isCollapsed ? 0 : 1)
                    .offset(x: 0, y: viewStore.isCollapsed ? 46 + 14 + 5 : 0)
                    // width: 56, height: 56
                    Button(
                        action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                viewStore.send(.toggleCollapsed)
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
                                .rotationEffect(viewStore.isCollapsed ? Angle(degrees: 0) : Angle(degrees: 135))
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
        attributes.entryInteraction = .absorbTouches
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
