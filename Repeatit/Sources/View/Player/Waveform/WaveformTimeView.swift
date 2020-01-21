//
//  WaveformTimeView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/08.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI
import RxSwift

struct WaveformTimeView: View {

    let player: Player

    @State var currentTime: Double = 0
    @State var duration: Double = 0

    private let disposeBag = DisposeBag()

    var body: some View {
        HStack {
            Text(secondsToFormat(time: currentTime))
                .foregroundColor(.systemWhite)
                .frame(width: 110, alignment: .center)
            Divider().foregroundColor(Color.classicBlue).background(Color.classicBlue)
            Text(secondsToFormat(time: duration))
                .foregroundColor(.systemWhite)
                .frame(width: 110, alignment: .center)
        }
        .frame(height: 32)
        .background(Color.systemBlack)
        .onAppear {
            self.duration = self.player.duration
            self.player.currentPlayTimeObservable
                .subscribe(onNext: { currentTime in
                    self.currentTime = currentTime
                })
                .disposed(by: self.disposeBag)
        }
    }

    private func secondsToFormat(time: Double) -> String {
        let hour = Int(time / 3600)
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let remainder = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String.init(format: "%02d:%02d:%02d.%02d", hour, minutes, Int(seconds), remainder)
    }
}

struct WaveformTimeView_Previews: PreviewProvider {
    static var previews: some View {
        WaveformTimeView(player: BasicPlayer())
    }
}
