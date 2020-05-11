//
//  DocumentsExplorer.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import SwiftUI

struct DocumentsExplorer: View {
    @ObservedObject var model: ViewModel
    
    var body: some View {
        NavigationView {
            DocumentsExplorerList(model: .init(url: URL.homeDirectory))
        }
    }
}

extension DocumentsExplorer {
    class ViewModel: ObservableObject {
        init() {
        }
    }
}

struct DocumentsExplorer_Previews: PreviewProvider {
    static var previews: some View {
        DocumentsExplorer(model: .init())
    }
}
