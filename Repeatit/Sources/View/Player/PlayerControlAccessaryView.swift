//
//  PlayerControlAccessaryView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/04/04.
//

import UIKit
import SnapKit

class PlayerControlAccessoryView: UIStackView {
    static let height: CGFloat = 40

    private let player: Player

    // MARK: - UI Components
    private let moveBackward1SecondsButton = PlayerMoveControlButton(direction: .backward, seconds: 1)
    private let moveBackward5SecondsButton = PlayerMoveControlButton(direction: .backward, seconds: 5)
    private let moveForward1SecondsButton = PlayerMoveControlButton(direction: .forward, seconds: 1)
    private let moveForward5SecondsButton = PlayerMoveControlButton(direction: .forward, seconds: 5)
    private let playButton = UIImageView(image: UIImage(systemName: "play.fill"))
        .apply {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemBlack
        }
    // MARK: -

    init(player: Player) {
        self.player = player
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
        snp.addSubview(backgroundView) { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        snp.addArrangedSubview(moveBackward1SecondsButton) { make in
            make.width.height.equalTo(32)
        }
        snp.addArrangedSubview(moveBackward5SecondsButton) { make in
            make.width.height.equalTo(32)
        }
        snp.addArrangedSubview(playButton) { make in
            make.width.height.equalTo(32)
        }
        snp.addArrangedSubview(moveForward1SecondsButton) { make in
            make.width.height.equalTo(32)
        }
        snp.addArrangedSubview(moveForward5SecondsButton) { make in
            make.width.height.equalTo(32)
        }
    }
}
