//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftEntryKit
import SwiftUI

struct DocumentsExplorerList: View {
    @ObservedObject var model: ViewModel

    @ViewBuilder
    var body: some View {
        ZStack {
            if model.isEditing {
                ZStack {
                    DocumentsExplorerMultiSelectableList(items: self.model.items)
                        .onPreferenceChange(DocumentsExplorerSelectedItemsKey.self, perform: { self.model.selectedItems = $0 })
                        .navigationBarBackButtonHidden(true)
                        .navigationBarItems(
                            leading: Button(action: { self.model.isEditing = false }) {
                                Image(systemName: "xmark")
                                    .padding(12)
                                    .foregroundColor(.systemBlack)
                            },
                            trailing: HStack {
                                Button(action: { self.model.isDestinationViewShowing = true }) {
                                    Image(systemName: "arrow.right.square")
                                        .padding(12)
                                        .foregroundColor(.systemBlack)
                                }
                                Button(action: {
                                    self.model.selectedItems.forEach { try? FileManager.default.removeItem(at: $0.url) }
                                    self.model.refresh()
                                }) {
                                    Image(systemName: "trash")
                                        .padding(12)
                                        .foregroundColor(.systemBlack)
                                }
                            }
                    )
                    .padding(.bottom, 50)
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            Button(
                                action: { self.model.renameButtonTapped() },
                                label: {
                                    Text("Rename")
                                        .foregroundColor(Color.white)
                                })
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 50)
                                .padding(.bottom, geometry.safeAreaInsets.bottom)
                                .background(self.renameButtonColor)
                                .disabled(self.model.isRenameButtonDisabled)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            } else {
                List(self.model.items, id: \.name) { item in
                    if item.isDirectory {
                        NavigationLink(destination: DocumentsExplorerList(model: .init(url: item.url))) {
                            DocumentsExplorerRow(item: item)
                        }
                    } else {
                        DocumentsExplorerRow(item: item)
                            .onTapGesture { self.model.audioItemTapped(item: item) }
                    }
                }
                    .navigationBarItems(
                        // Editing 에서 navigation item 이 사라지지 않는다.
                        leading: Color.systemWhite.opacity(0),
                        trailing: HStack {
                            Button(action: { self.model.isEditing = true }) {
                                Image(systemName: "list.bullet")
                                    .padding(12)
                                    .foregroundColor(.systemBlack)
                            }
                            Button(action: {
                                self.model.createNewDirectory()
                                self.model.refresh()
                            }) {
                                Image(systemName: "folder.badge.plus")
                                    .padding(12)
                                    .foregroundColor(.systemBlack)
                            }
                        }
                    )
            }
        }
        .onPreferenceChange(DocumentsExplorerSelectedItemsKey.self, perform: { self.model.selectedItems = $0 })
        .navigationBarTitle(model.url.lastPathComponent)
        .background(EmptyView().sheet(item: $model.selectedItem, content: { PlayerView(item: AudioItem(url: $0.url), audioPlayer: self.model.audioPlayer) }))
        .background(EmptyView().sheet(isPresented: $model.isDestinationViewShowing, content: {
            NavigationView {
                DocumentsExplorerDestinationView(
                    url: URL.documentsURL,
                    selectedFiles: self.model.selectedItems,
                    moveButtonTapped: self.model.destinationMoveButtonTapped,
                    closeButtonTapped: self.model.destinationCloseButtonTapped
                )
            }
        }))
        .onAppear { self.model.refresh() }
    }
    
    private var renameButtonColor: Color {
        return self.model.isRenameButtonDisabled ? Color.classicBlue.opacity(0.6) : Color.classicBlue
    }
}

extension DocumentsExplorerList {
    class ViewModel: ObservableObject {
        let audioPlayer = BasicAudioPlayer()
        let url: URL
        @Published var items: [DocumentsExplorerItem] = []
        @Published var selectedItem: DocumentsExplorerItem?
        @Published var isEditing: Bool
        @Published var isDestinationViewShowing: Bool
        @Published var isRenameButtonDisabled: Bool
        var selectedItems: Set<DocumentsExplorerItem> = [] {
            didSet { isRenameButtonDisabled = selectedItems.count != 1 }
        }

        init(
            url: URL,
            items: [DocumentsExplorerItem]? = nil,
            selectedItem: DocumentsExplorerItem? = nil,
            selectedItems: Set<DocumentsExplorerItem>? = nil,
            isEditing: Bool = false,
            isDestinationViewShowing: Bool = false,
            isRenameButtonDisabled: Bool = false
        ) {
            self.url = url
            self.items = items ?? FileManager.default.getFiles(in: url).map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
            self.selectedItem = selectedItem
            self.selectedItems = selectedItems ?? []
            self.isEditing = isEditing
            self.isDestinationViewShowing = isDestinationViewShowing
            self.isRenameButtonDisabled = isRenameButtonDisabled
        }

        func refresh() {
            items = FileManager.default.getFiles(in: url)
                .map { DocumentsExplorerItem(url: $0.url, isDirectory: $0.isDir) }
        }

        func createNewDirectory() {
            let _ = try? FileManager.default.createDirectory(
                at: self.url.appendingPathComponent(NSUUID().uuidString),
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        func audioItemTapped(item: DocumentsExplorerItem) {
            selectedItem = item
            playItemsInDirectory(with: item)
        }
        
        func renameButtonTapped() {
            guard let itemForRename = self.selectedItems.first else { return }
            var attributes = EKAttributes()
            attributes.name = "EntryForRename"
            attributes.displayDuration = .infinity
            attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
            attributes.position = .center
            let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
            let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
            attributes.positionConstraints.keyboardRelation = keyboardRelation
            SwiftEntryKit.display(
                builder: {
                    DocumentsExplorerRenamePopup(
                        textInput: itemForRename.name,
                        positiveButtonTapped: { [weak self] in
                            try? FileManager.default.moveItem(at: itemForRename.url, to: itemForRename.url.deletingLastPathComponent().appendingPathComponent($0))
                            self?.isEditing = false
                            self?.refresh()
                            SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename"))
                        },
                        negativeButtonTapped: { SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename")) }
                    )
                },
                using: attributes
            )
        }

        func destinationMoveButtonTapped(_ url: URL) {
            moveSelectedItems(to: url)
            dismissSheet()
        }

        func destinationCloseButtonTapped() {
            dismissSheet()
        }

        private func dismissSheet() {
            isDestinationViewShowing = false
        }

        private func moveSelectedItems(to: URL) {
            selectedItems.forEach {
                try? FileManager.default.moveItem(at: $0.url, to: to.appendingPathComponent($0.name))
            }
            refresh()
        }

        private func playItemsInDirectory(with item: DocumentsExplorerItem) {
            do {
                let items = FileManager.default
                    .getDocumentsItems(in: item.url.deletingLastPathComponent())
                    .filter { !$0.isDirectory && $0.isAudioFile }
                    .map { AudioItem(url: $0.url) }
                let startAt = items.firstIndex (where: { $0.url == item.url }) ?? 0
                let newItems = startAt == 0 ? items : Array(items[startAt...]) + Array(items[0..<startAt])
                try self.audioPlayer.play(with: newItems)
            } catch {
                // TODO: Should show alert and why
            }
        }
    }
}

struct DocumentsExplorerList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerList(model: .init(url: URL.documentsURL, isEditing: true))
            DocumentsExplorerList(model: .init(url: URL.documentsURL, isEditing: false))
        }
    }
}
