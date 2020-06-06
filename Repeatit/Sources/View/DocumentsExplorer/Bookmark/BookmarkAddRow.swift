//
//  BookmarkAddRow.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import SwiftUI

struct BookmarkAddRow: View {
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "plus.circle")
            Text("Add Bookmark")
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 44)
    }
}

struct BookmarkAddRow_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkAddRow()
            .previewLayout(.sizeThatFits)
    }
}
