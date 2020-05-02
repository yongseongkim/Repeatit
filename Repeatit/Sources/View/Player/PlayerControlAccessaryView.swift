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
    static let height: CGFloat = 48

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
        alignment = .fill
        distribution = .fillEqually
        spacing = 10
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 5, leading: 15, bottom: 5, trailing: 15)

        let backgroundView = UIView().apply {
            $0.backgroundColor = .systemWhite
            $0.layer.shadowColor = UIColor.systemBlack.cgColor
            $0.layer.shadowRadius = 10
            $0.layer.shadowOffset = CGSize(width: 0, height: 0)
            $0.layer.shadowOpacity = 0.2
        }
        snp.addSubview(backgroundView) { $0.top.leading.bottom.trailing.equalToSuperview() }
        addArrangedSubview(moveBackward5SecondsButton)
        addArrangedSubview(moveBackward1SecondsButton)
        addArrangedSubview(playButton)
        addArrangedSubview(moveForward1SecondsButton)
        addArrangedSubview(moveForward5SecondsButton)

        audioPlayer.isPlayingPublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] isPlaying in
                guard let self = self else { return }
                self.playButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
            })
            .store(in: &cancellables)
        moveBackward5SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                self?.audioPlayer.moveBackward(seconds: 5)
            })
            .store(in: &cancellables)
        moveBackward1SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                self?.audioPlayer.moveBackward(seconds: 1)
            })
            .store(in: &cancellables)
        playButton.publisher(for: UIControl.Event.touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                guard let isPlaying = self?.audioPlayer.isPlaying else { return }
                isPlaying ? self?.audioPlayer.pause() : self?.audioPlayer.resume()
            })
            .store(in: &cancellables)
        moveForward1SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                self?.audioPlayer.moveForward(seconds: 1)
            })
            .store(in: &cancellables)
        moveForward5SecondsButton.button.publisher(for: UIControl.Event.touchUpInside)
            .sink(receiveValue: { [weak self] _ in
                self?.audioPlayer.moveForward(seconds: 5)
            })
            .store(in: &cancellables)
    }
}
