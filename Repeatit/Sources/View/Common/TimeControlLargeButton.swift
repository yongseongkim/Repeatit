//
//  TimeControlButton.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import SwiftUI

enum TimeControlDirection {
    case forward
    case backward
}

struct TimeControlLargeButton: View {
    let direction: TimeControlDirection
    let seconds: Int

    var body: some View {
        ZStack {
            Image(systemName: direction == .forward ? "goforward" : "gobackward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.systemBlack)
                .frame(width: 30, height: 30)
            Text("\(seconds)")
                .font(.system(size: 17))
                .fontWeight(.semibold)
                .foregroundColor(Color.systemBlack)
                .offset(x: 0, y: 1)
        }
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
}

struct TimeControlSmallButton: View {
    let direction: TimeControlDirection
    let seconds: Int

    var body: some View {
        ZStack {
            Image(systemName: direction == .forward ? "goforward" : "gobackward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.systemBlack)
                .frame(width: 28, height: 28)
            Text("\(seconds)")
                .font(.system(size: 15))
                .fontWeight(.semibold)
                .foregroundColor(Color.systemBlack)
                .offset(x: 0, y: 1)
        }
        .frame(width: 50, height: 50)
        .contentShape(Rectangle())
    }
}

struct InputAccessaryTimeControlButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimeControlSmallButton(direction: .forward, seconds: 5)
                .previewLayout(.sizeThatFits)
            TimeControlSmallButton(direction: .forward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlSmallButton(direction: .backward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlSmallButton(direction: .backward, seconds: 5)
                .previewLayout(.sizeThatFits)
        }
    }
}

struct TimeControlButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimeControlLargeButton(direction: .forward, seconds: 5)
                .previewLayout(.sizeThatFits)
            TimeControlLargeButton(direction: .forward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlLargeButton(direction: .backward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlLargeButton(direction: .backward, seconds: 5)
                .previewLayout(.sizeThatFits)
        }
    }
}
