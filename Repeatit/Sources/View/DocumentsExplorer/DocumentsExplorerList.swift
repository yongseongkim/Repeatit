//
//  DocumentsExplorerList.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct DocumentsExplorerList: View {
    let url: URL
    let player: Player = BasicPlayer()

    @State var items = [DocumentsExplorerItem]()
    @State var isShowingPlayer = false

    var body: some View {
        List(items, id: \.name) { item in
            if item.isDirectory {
                NavigationLink(destination: DocumentsExplorerList(url: self.url.appendingPathComponent(item.name))) {
                    DocumentsExplorerRow(item: item)
                }
            } else {
                DocumentsExplorerRow(item: item)
                    .onTapGesture {
                        self.playItemsInDirectory(with: item)
                    }
                    .sheet(isPresented: self.$isShowingPlayer) {
                        PlayerView(
                            item: PlayItem(url: self.url.appendingPathComponent(item.name)),
                            player: self.player
                        )
                    }
            }
        }
        .navigationBarTitle(url.lastPathComponent)
        .navigationBarItems(
            trailing: Button(action: {
                let _ = try? FileManager.default.createDirectory(
                    at: self.url.appendingPathComponent(NSUUID().uuidString),
                    withIntermediateDirectories: true,
                    attributes: nil
                )
                self.loadItems()
            }) {
                Image(systemName: "folder.fill.badge.plus").foregroundColor(.systemBlack)
            }
        )
        .onAppear {
            self.loadItems()
        }
    }

    private func loadItems() {
        self.items = self.getItemsInDirectory()
    }

    private func playItemsInDirectory(with item: DocumentsExplorerItem) {
        do {
            let items = self.getItemsInDirectory()
                .filter { !$0.isDirectory }
                .map { PlayItem(url: self.url.appendingPathComponent($0.name)) }
            let startAt = items.firstIndex (where: { $0.url == self.url.appendingPathComponent(item.name) }) ?? 0
            let newItems = startAt == 0 ? items : Array(items[startAt...]) + Array(items[0..<startAt])
            try self.player.play(with: newItems)
            self.isShowingPlayer = true
        } catch {
            // TODO: Should show alert and why
            self.isShowingPlayer = false
        }
    }

    private func getItemsInDirectory() -> [DocumentsExplorerItem] {
        let contents = (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? [String]()
        var isDir : ObjCBool = false
        return contents.map { filename -> DocumentsExplorerItem in
            let fileURL = URL.documentsURL.appendingPathComponent(filename)
            let _ = FileManager.default.fileExists(atPath: fileURL.path, isDirectory:&isDir)
            return DocumentsExplorerItem(
                name: filename,
                isDirectory: isDir.boolValue
            )
        }
    }
}

struct DocumentsExplorerList_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorerList(
            url: URL.documentsURL
        )
    }
}
