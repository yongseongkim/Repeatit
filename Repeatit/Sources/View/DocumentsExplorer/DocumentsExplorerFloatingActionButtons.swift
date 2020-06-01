//
//  DocumentsExplorerFloatingActionButtons.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerFloatingActionButtons: View {
    @EnvironmentObject var store: DocumentsExplorerStore
    @State var isFolding: Bool = true

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 15) {
                    DocumentsExplorerFloatingActionButton(
                        imageSystemName: "play.rectangle.fill",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    textInput: "",
                                    title: "YouTube Link",
                                    placeholder: "Please Enter a YouTube link.",
                                    positiveButton: ("Confirm", {
                                        guard let youtubeId = $0.getYouTubeId() else { return }
                                        self.store.createYouTubeFile(videoId: youtubeId)
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    }),
                                    negativeButton: ("Cancel", {
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    })
                                )
                            }
                        }
                    )
                    .opacity(isFolding ? 0 : 1)
                    .offset(x: 0, y: isFolding ? 127 : 0)
                    DocumentsExplorerFloatingActionButton(
                        imageSystemName: "folder",
                        onTapGesture: {
                            self.showPopup {
                                SingleTextFieldPopup(
                                    textInput: "",
                                    title: "Directory",
                                    placeholder: "Please Enter a new directory name.",
                                    positiveButton: ("Confirm", {
                                        self.store.createNewDirectory(dirName: $0)
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    }),
                                    negativeButton: ("Cancel", {
                                        SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                    })
                                )
                            }
                        }
                    )
                    .opacity(isFolding ? 0 : 1)
                    .offset(x: 0, y: isFolding ? 66 : 0)
                    Button(
                        action: {
                            withAnimation(.easeIn(duration: 0.15)) {
                                self.isFolding = !self.isFolding
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
                                .rotationEffect(isFolding ? Angle(degrees: 0) : Angle(degrees: 135))
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

struct DocumentsExplorerFloatingActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerFloatingActionButtons()
                .background(Color.systemGray6)
                .environmentObject(DocumentsExplorerStore())
                .environment(\.colorScheme, .light)
                .previewLayout(.fixed(width: 360, height: 300))
            DocumentsExplorerFloatingActionButtons()
                .background(Color.systemGray6)
                .environmentObject(DocumentsExplorerStore())
                .environment(\.colorScheme, .dark)
                .previewLayout(.fixed(width: 360, height: 300))
        }
    }
}
