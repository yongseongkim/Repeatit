//
//  PlayerControlAccessaryView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/04.
//

import Combine
import UIKit
import SnapKit

class PlayerControlAccessoryView: UIStackView {
    static let height: CGFloat = 40

    private let audioPlayer: AudioPlayer
    private var cancellables: [AnyCancellable] = []

    // MARK: - UI Components
    private let moveBackward5SecondsButton = PlayerMoveControlButton(direction: .backward, seconds: 5)
    private let moveBackward1SecondsButton = PlayerMoveControlButton(direction: .backward, seconds: 1)
    private let moveForward1SecondsButton = PlayerMoveControlButton(direction: .forward, seconds: 1)
    private let moveForward5SecondsButton = PlayerMoveControlButton(direction: .forward, seconds: 5)
    private let playButton = UIButton(type: .custom).apply {
        $0.tintColor = .systemBlack
        $0.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    // MARK: -

    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
        super.init(frame: .zero)
        initialize()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialize() {
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15)

        let backgroundView = UIView().apply {
            $0.backgroundColor = .systemWhite
            $0.layer.shadowColor = UIColor.systemBlack.cgColor
            $0.layer.shadowRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
            $0.layer.shadowOpacity = 0.2
        }
        snp.addSubview(backgroundView) { $0.top.leading.bottom.trailing.equalToSuperview() }
        snp.addArrangedSubview(moveBackward5SecondsButton) { $0.width.height.equalTo(32) }
        snp.addArrangedSubview(moveBackward1SecondsButton) { $0.width.height.equalTo(32) }
        snp.addArrangedSubview(playButton) { $0.width.height.equalTo(32) }
        snp.addArrangedSubview(moveForward1SecondsButton) { $0.width.height.equalTo(32) }
        snp.addArrangedSubview(moveForward5SecondsButton) { $0.width.height.equalTo(32) }

        cancellables += [
            audioPlayer.isPlayingPublisher
                .receive(on: RunLoop.main)
                .sink(receiveValue: { [weak self] isPlaying in
                    guard let self = self else { return }
                    self.playButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
                }),
            moveBackward5SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.audioPlayer.moveBackward(seconds: 5)
                }),
            moveBackward1SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.audioPlayer.moveBackward(seconds: 1)
                }),
            playButton.publisher(for: UIControl.Event.touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    guard let isPlaying = self?.audioPlayer.isPlaying else { return }
                    isPlaying ? self?.audioPlayer.pause() : self?.audioPlayer.resume()
                }),
            moveForward1SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.audioPlayer.moveForward(seconds: 1)
                }),
            moveForward5SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
                .sink(receiveValue: { [weak self] _ in
                    self?.audioPlayer.moveForward(seconds: 5)
                })
        ]
    }
}
