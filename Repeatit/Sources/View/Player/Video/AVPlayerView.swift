//
//  AVPlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import AVFoundation
import SwiftUI

struct AVPlayerView: UIViewRepresentable {
    let videoLayer: AVPlayerLayer

    func makeUIView(context: Context) -> AVPlayerUIView {
        return AVPlayerUIView(videoLayer: videoLayer)
    }

    func updateUIView(_ uiView: AVPlayerUIView, context: Context) {
    }
}

class AVPlayerUIView: UIView {
    private let videoLayer: AVPlayerLayer

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(videoLayer: AVPlayerLayer) {
        self.videoLayer = videoLayer
        super.init(frame: .zero)
        self.layer.addSublayer(videoLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.videoLayer.frame = self.bounds
    }
}
