//
//  PlayerMoveControlButton.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/05.
//

import SwiftUI
import UIKit

struct PlayerMoveControlButtonUI: UIViewRepresentable {
    let direction: PlayerMoveControlButton.Direction
    let seconds: Int

    func makeUIView(context: Context) -> PlayerMoveControlButton {
        return PlayerMoveControlButton(direction: direction, seconds: seconds)
    }

    func updateUIView(_ uiView: PlayerMoveControlButton, context: Context) {
    }
}


class PlayerMoveControlButton: UIView {
    enum Direction {
        case forward
        case backward
    }

    private let direction: Direction
    private let seconds: Int

    // MARK: UI Components
    private let directionImageView = UIImageView().apply {
        $0.tintColor = .systemBlack
        $0.contentMode = .scaleAspectFit
    }
    private let secondsLabel = UILabel().apply {
        $0.textColor = .systemBlack
    }
    // MARK: -

    init(direction: Direction, seconds: Int) {
        self.direction = direction
        self.seconds = seconds
        super.init(frame: .zero)
        intialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        secondsLabel.font = .systemFont(ofSize: frame.height * 0.6 - 5, weight: .bold)
    }

    private func intialize() {
        backgroundColor = .clear
        directionImageView.image = UIImage(systemName: direction == .forward ? "goforward" : "gobackward")
        snp.addSubview(directionImageView) { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        secondsLabel.text = "\(seconds)"
        snp.addSubview(secondsLabel) { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
}
