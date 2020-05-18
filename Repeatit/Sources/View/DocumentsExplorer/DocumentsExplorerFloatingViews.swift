//
//  DocumentsExplorerFloatingViews.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/18.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerFloatingViews: View {
    let store: DocumentsExplorerStore

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 15) {
                    Button(
                        action: {
                            var attributes = EKAttributes()
                            attributes.name = "EntryForYouTube"
                            attributes.displayDuration = .infinity
                            attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
                            attributes.position = .center
                            attributes.entranceAnimation = .init(
                                scale: .init(from: 0.3, to: 1, duration: 0.15),
                                fade: .init(from: 0.8, to: 1, duration: 0.1)
                            )
                            attributes.exitAnimation = .init(
                                scale: .init(from: 1, to: 0.3, duration: 0.15),
                                fade: .init(from: 1, to: 0.0, duration: 0.1)
                            )
                            let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
                            let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                            attributes.positionConstraints.keyboardRelation = keyboardRelation
                            SwiftEntryKit.display(
                                builder: {
                                    DocumentsExplorerCreateYouTubePopup(
                                        textInput: "",
                                        onPositiveButtonTapGesture: {
                                            guard let youtubeId = $0.getYouTubeId() else { return }
                                            self.store.createYouTubeFile(videoId: youtubeId)
                                            SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube"))
                                        },
                                        onNegativeButtonTapGesture: { SwiftEntryKit.dismiss(.specific(entryName: "EntryForYouTube")) }
                                    )
                                },
                                using: attributes
                            )
                        },
                        label: {
                            Image(systemName: "play.rectangle.fill")
                                .resizable()
                                .foregroundColor(Color.systemBlack)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        }
                    )
                    .frame(width: 56, height: 56)
                    .background(Color.systemGray5)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.35), radius: 5)
                    Button(
                        action: { self.store.createNewDirectory() },
                        label: {
                            Image(systemName: "folder")
                                .resizable()
                                .foregroundColor(Color.systemBlack)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        }
                    )
                    .frame(width: 56, height: 56)
                    .background(Color.systemGray5)
                    .cornerRadius(28)
                    .shadow(color: Color.black.opacity(0.35), radius: 5)
                }
            }
        }
        .padding([.bottom, .trailing], 20)
    }
}

struct DocumentsExplorerFloatingViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerFloatingViews(store: DocumentsExplorerStore())
                .previewLayout(.fixed(width: 360, height: 300))
                .background(Color.systemGray6)
                .environment(\.colorScheme, .light)
            DocumentsExplorerFloatingViews(store: DocumentsExplorerStore())
                .previewLayout(.fixed(width: 360, height: 300))
                .background(Color.systemGray6)
                .environment(\.colorScheme, .dark)
        }
    }
}
