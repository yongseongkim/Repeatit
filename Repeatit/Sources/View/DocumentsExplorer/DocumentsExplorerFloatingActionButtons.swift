//
//  DocumentsExplorerFloatingActionButtons.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import MobileCoreServices
import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerFloatingActionButtons: View {
    @ObservedObject var model: ViewModel
    let listner: Listener?

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 15) {
                    DocumentsExplorerFloatingActionButton(
                        imageSystemName: "music.note",
                        onTapGesture: { self.model.isDocumentsPickerShowing = true }
                    )
                    .sheet(
                        isPresented: .init(get: { self.model.isDocumentsPickerShowing }, set: { self.model.isDocumentsPickerShowing = $0 }),
                        content: {
                            DocumentsPickerView(
                                documentTypes: [(kUTTypeAudio as String), (kUTTypeMovie as String), (kUTTypeVideo as String)],
                                listener: .init(
                                    onPickDocuments: { self.listner?.onCopyDocumentFiles($0) },
                                    onCancelPick: {}
                                )
                            )
                        }
                    )
                    .opacity(self.model.isFolding ? 0 : 1)
                    .offset(x: 0, y: self.model.isFolding ? 188 : 0)
                    DocumentsExplorerFloatingActionButton(
                        imageSystemName: "play.rectangle",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    textInput: "",
                                    title: "YouTube",
                                    message: "Please Enter a YouTube link.",
                                    placeholder: "ex) https://youtu.be/929plYk1lDc",
                                    positiveButton: ("Confirm", {
                                        guard let youtubeId = $0.getYouTubeId() else { return }
                                        self.listner?.onCreateYouTubeConfirm(youtubeId)
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    }),
                                    negativeButton: ("Cancel", {
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    })
                                )
                            }
                        }
                    )
                    .opacity(self.model.isFolding ? 0 : 1)
                    .offset(x: 0, y: self.model.isFolding ? 127 : 0)
                    DocumentsExplorerFloatingActionButton(
                        imageSystemName: "folder",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    textInput: "",
                                    title: "Directory",
                                    message: "Please Enter a new directory name.",
                                    placeholder: "ex) NewDirectory",
                                    positiveButton: ("Confirm", {
                                        self.listner?.onCreateDirectoryConfirm($0)
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    }),
                                    negativeButton: ("Cancel", {
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    })
                                )
                            }
                        }
                    )
                    .opacity(self.model.isFolding ? 0 : 1)
                    .offset(x: 0, y: self.model.isFolding ? 66 : 0)
                    Button(
                        action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                self.model.isFolding = !self.model.isFolding
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
                                .rotationEffect(self.model.isFolding ? Angle(degrees: 0) : Angle(degrees: 135))
                                .shadow(color: Color.black.opacity(0.35), radius: 5)
                        }
                    )
                }
            }
        }
        .padding([.bottom, .trailing], 20)
    }

    private func showPopup<Content: View>(@ViewBuilder builder: @escaping () -> Content) {
        var attributes = EKAttributes()
        attributes.name = "EntryForYouTube"
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

extension DocumentsExplorerFloatingActionButtons {
    class ViewModel: ObservableObject {
        @Published var isFolding: Bool = true
        @Published var isDocumentsPickerShowing: Bool = false
    }

    struct Listener {
        let onCopyDocumentFiles: (([URL]) -> Void)
        let onCreateDirectoryConfirm: ((String) -> Void)
        let onCreateYouTubeConfirm: ((String) -> Void)
    }
}

struct DocumentsExplorerFloatingActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerFloatingActionButtons(
                model: .init(),
                listner: .init(
                    onCopyDocumentFiles: { _ in },
                    onCreateDirectoryConfirm: { _ in },
                    onCreateYouTubeConfirm: { _ in }
                )
            )
                .background(Color.systemGray6)
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 360, height: 300))
            DocumentsExplorerFloatingActionButtons(
                model: .init(),
                listner: .init(
                    onCopyDocumentFiles: { _ in },
                    onCreateDirectoryConfirm: { _ in },
                    onCreateYouTubeConfirm: { _ in }
                )
            )
                .background(Color.systemGray6)
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 360, height: 300))
        }
    }
}
