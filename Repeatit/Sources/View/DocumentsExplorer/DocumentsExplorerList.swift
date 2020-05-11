//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftEntryKit
import SwiftUI
import RealmSwift

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
                                Button(action: {
                                    guard self.model.selectedItems.count != 0 else { return }
                                    self.model.isDestinationViewShowing = true
                                }) {
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
                                action: { self.model.renameButtonAction() },
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
                            .onTapGesture { self.model.onAudioItemRowTapGesture(item: item) }
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
                    url: URL.homeDirectory,
                    selectedFiles: self.model.selectedItems,
                    moveButtonAction: self.model.moveButtonActionInDestinationView,
                    closeButtonAction: self.model.closeButtonActionInDestinationView
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

        func onAudioItemRowTapGesture(item: DocumentsExplorerItem) {
            selectedItem = item
            playItemsInDirectory(with: item)
        }
        
        func renameButtonAction() {
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
                        onPositiveButtonTapGesture: { [weak self] in
                            self?.rename(item: itemForRename, newName: $0)
                            self?.isEditing = false
                            self?.refresh()
                            SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename"))
                        },
                        onNegativeButtonTapGesture: { SwiftEntryKit.dismiss(.specific(entryName: "EntryForRename")) }
                    )
                },
                using: attributes
            )
        }

        func moveButtonActionInDestinationView(_ url: URL) {
            moveSelectedItems(to: url)
            dismissSheet()
        }

        func closeButtonActionInDestinationView() {
            dismissSheet()
        }

        private func dismissSheet() {
            isDestinationViewShowing = false
        }

        private func moveSelectedItems(to: URL) {
            let realm = try! Realm()
            selectedItems.forEach { item in
                let fromURL = item.url
                let toURL = to.appendingPathComponent(item.name)
                do {
                    try FileManager.default.moveItem(at: fromURL, to: toURL)
                    if let existed = realm.object(ofType: DictationNote.self, forPrimaryKey: DictationNote.keyPath(url: fromURL)) {
                        let updated = DictationNote().apply {
                            $0.relativePath = DictationNote.keyPath(url: toURL)
                            $0.note = existed.note
                            $0.createdAt = existed.createdAt
                            $0.updatedAt = Date()
                        }
                        try! realm.write {
                            realm.add(updated)
                            realm.delete(existed)
                        }
                    }
                } catch let exception {
                    var attributes = EKAttributes()
                    attributes.name = "EntryForRenameFailure"
                    attributes.displayDuration = 3
                    attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
                    attributes.position = .center
                    let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
                    let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
                    attributes.positionConstraints.keyboardRelation = keyboardRelation
                    SwiftEntryKit.display(
                        builder: {
                            Text("Failure")
                        },
                        using: attributes
                    )
                }
            }
            refresh()
        }

        private func rename(item: DocumentsExplorerItem, newName: String) {
            let fromURL = item.url
            let toURL = item.url.deletingLastPathComponent().appendingPathComponent(newName)
            do {
                try FileManager.default.moveItem(at: fromURL, to: toURL)
                let realm = try! Realm()
                if let existed = realm.object(ofType: DictationNote.self, forPrimaryKey: DictationNote.keyPath(url: fromURL)) {
                    let updated = DictationNote().apply {
                        $0.relativePath = DictationNote.keyPath(url: toURL)
                        $0.note = existed.note
                        $0.createdAt = existed.createdAt
                        $0.updatedAt = Date()
                    }
                    try! realm.write {
                        realm.add(updated)
                        realm.delete(existed)
                    }
                }
            } catch let exception {
                showExceptionMessage(exception)
            }
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
            } catch let exception {
                showExceptionMessage(exception)
            }
        }

        private func showExceptionMessage(_ exception: Error) {
            var attributes = EKAttributes()
            attributes.name = "EntryForRenameFailure"
            attributes.displayDuration = 2
            attributes.screenBackground = .color(color: EKColor(UIColor.black.withAlphaComponent(0.6)))
            attributes.position = .center
            let offset = EKAttributes.PositionConstraints.KeyboardRelation.Offset(bottom: 10, screenEdgeResistance: 20)
            let keyboardRelation = EKAttributes.PositionConstraints.KeyboardRelation.bind(offset: offset)
            attributes.positionConstraints.keyboardRelation = keyboardRelation
            SwiftEntryKit.display(
                builder: {
                    VStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Failure")
                                .foregroundColor(Color.systemBlack)
                                .padding(EdgeInsets(top: 30, leading: 25, bottom: 0, trailing: 25))
                            Text(exception.localizedDescription)
                                .foregroundColor(Color.systemBlack)
                                .padding(EdgeInsets(top: 30, leading: 25, bottom: 30, trailing: 25))
                        }
                        .frame(width: 290)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(8)
                        Spacer()
                    }
                },
                using: attributes
            )
        }
    }
}

struct DocumentsExplorerList_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DocumentsExplorerList(model: .init(url: URL.homeDirectory, isEditing: true))
                .previewLayout(.fixed(width: 320, height: 300))
            DocumentsExplorerList(model: .init(url: URL.homeDirectory, isEditing: false))
                .previewLayout(.fixed(width: 320, height: 300))
        }
    }
}
