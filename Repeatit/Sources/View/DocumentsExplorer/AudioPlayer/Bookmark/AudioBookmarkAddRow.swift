//
//  AudioBookmarkAddRow.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import SwiftUI

struct AudioBookmarkAddRow: View {
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "plus.circle")
            Text("Add Bookmark")
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(height: 44)
    }
}

struct AudioBookmarkAddRow_Previews: PreviewProvider {
    static var previews: some View {
        AudioBookmarkAddRow()
            .previewLayout(.sizeThatFits)
    }
}
