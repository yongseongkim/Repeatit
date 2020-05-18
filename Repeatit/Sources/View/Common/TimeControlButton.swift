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

struct TimeControlButton: View {
    let direction: TimeControlDirection
    let seconds: Int

    var body: some View {
        ZStack {
            Image(systemName: direction == .forward ? "goforward" : "gobackward")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.systemBlack)
                .frame(width: 34, height: 34)
            Text("\(seconds)")
                .font(.system(size: 19))
                .fontWeight(.bold)
                .foregroundColor(Color.systemBlack)
                .offset(x: 0, y: 2)
        }
        .frame(width: 50, height: 50)
        .contentShape(Rectangle())
    }
}

struct InputAccessaryTimeControlButton: View {
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
                .fontWeight(.bold)
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
            InputAccessaryTimeControlButton(direction: .forward, seconds: 5)
                .previewLayout(.sizeThatFits)
            InputAccessaryTimeControlButton(direction: .forward, seconds: 1)
                .previewLayout(.sizeThatFits)
            InputAccessaryTimeControlButton(direction: .backward, seconds: 1)
                .previewLayout(.sizeThatFits)
            InputAccessaryTimeControlButton(direction: .backward, seconds: 5)
                .previewLayout(.sizeThatFits)
        }
    }
}


struct TimeControlButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TimeControlButton(direction: .forward, seconds: 5)
                .previewLayout(.sizeThatFits)
            TimeControlButton(direction: .forward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlButton(direction: .backward, seconds: 1)
                .previewLayout(.sizeThatFits)
            TimeControlButton(direction: .backward, seconds: 5)
                .previewLayout(.sizeThatFits)
        }
    }
}

