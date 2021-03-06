//
//  SelectedDocumentsDestinationNavigatorView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/03.
//

import ComposableArchitecture
import SwiftUI

struct SelectedDocumentsDestinationNavigatorView: View {
    let store: Store<SelectedDocumentsDestinationNavigatiorState, SelectedDocumentsDestinationNavigatorAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        NavigationView { SelectedDocumentDestinationView(store: store, url: URL.homeDirectory) }
                            .accentColor(.systemBlack)
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Spacer()
                                Button(
                                    action: { viewStore.send(.cancelButtonTapped) },
                                    label: {
                                        Image(systemName: "xmark")
                                            .padding(12)
                                            .foregroundColor(.systemBlack)
                                    }
                                )
                                .padding([.top, .trailing], 10)
                            }
                            Spacer()
                        }
                    }
                    Button(
                        action: { viewStore.send(.confirmButtonTapped) },
                        label: { Text("Confirm").foregroundColor(Color.white) }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.classicBlue)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct SelectedDocumentDestinationView: View {
    let store: Store<SelectedDocumentsDestinationNavigatiorState, SelectedDocumentsDestinationNavigatorAction>
    let url: URL

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List(viewStore.documents[url] ?? [], id: \.nameWithExtension) { item in
                if item.isDirectory && !viewStore.selectedDocuments.contains(item) {
                    NavigationLink(
                        destination: SelectedDocumentDestinationView(store: store, url: item.url),
                        label: { DocumentExplorerRow(document: item) }
                    )
                } else {
                    DocumentExplorerRow(document: item).opacity(0.6)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(url.lastPathComponent)
            .onAppear { viewStore.send(.destinationViewAppeared(url: url)) }
        }
    }
}

struct SelectedDocumentsDestinationNavigatorView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedDocumentsDestinationNavigatorView(
            store: .init(
                initialState: .init(
                    mode: .move,
                    currentURL: URL.homeDirectory,
                    documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                    selectedDocuments: [Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))]
                ),
                reducer: selectedDocumentsDestinationNavigatorReducer,
                environment: SelectedDocumentsDestinationNavigatiorEnvironment(fileManager: .default)
            )
        )
    }
}
