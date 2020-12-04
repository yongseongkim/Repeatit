//
//  YouTubeContentView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/16.
//

import SwiftUI
import youtube_ios_player_helper

struct YouTubeContentView: UIViewRepresentable {
    let youtubeLayer: YTPlayerView

    func makeUIView(context: Context) -> YouTubeContentUIView {
        return YouTubeContentUIView(youtubeLayer: youtubeLayer)
    }

    func updateUIView(_ uiView: YouTubeContentUIView, context: Context) {
    }
}

class YouTubeContentUIView: UIView {
    fileprivate let youtubeLayer: YTPlayerView

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(youtubeLayer: YTPlayerView) {
        self.youtubeLayer = youtubeLayer
        super.init(frame: .zero)
        self.addSubview(youtubeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        youtubeLayer.frame = bounds
    }
}
