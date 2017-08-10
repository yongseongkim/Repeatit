//
//  PlayerView.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 4. 11..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate {
    func playerViewTapped()
}

class PlayerView: UIView {
    
    static let shared = PlayerView()
    
    class func isVisible() -> Bool {
        return !PlayerView.shared.isHidden && (PlayerView.shared.alpha == 1.0)
    }
    
    class func height() -> CGFloat {
        return 60
    }

    //MARK: UI Components
    fileprivate let albumCoverImageView = UIImageView().then { (imageView) in
        imageView.contentMode = .scaleAspectFit
    }
    fileprivate let titleLabel = UILabel().then { (label) in
        label.textColor = UIColor.black
        label.font = label.font.withSize(15)
    }
    fileprivate let backgroundButton = UIButton()
    fileprivate let playButton = UIButton().then { (button) in
        button.setImage(UIImage(named: "btn_play_44pt"), for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
    }

    //MARK: Properties
    public var delegate: PlayerViewDelegate?
    
    init() {
        super.init(frame: .zero)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.backgroundColor = UIColor.gray243.withAlphaComponent(0.5)
        self.addSubview(self.albumCoverImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.backgroundButton)
        self.addSubview(self.playButton)
        self.albumCoverImageView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(40)
        }
        self.titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.albumCoverImageView.snp.right).offset(10)
            make.centerY.equalTo(self)
        }
        self.backgroundButton.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        self.playButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.titleLabel.snp.right).offset(10)
            make.right.equalTo(self).offset(-10)
            make.centerY.equalTo(self)
            make.width.height.equalTo(44)
        }
        
        self.playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchDown)
        self.backgroundButton.addTarget(self, action: #selector(backgroundButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func backgroundButtonTapped() {
        self.delegate?.playerViewTapped()
    }
    
    @objc fileprivate func playButtonTapped() {
        if Player.shared.state.isPlaying {
            Player.shared.pause()
        } else {
            Player.shared.resume()
        }
    }
    
    public func setup() {
        guard let item = Player.shared.currentItem else {
            return
        }
        if let artwork = item.artwork {
            self.albumCoverImageView.image = artwork
        } else {
            self.albumCoverImageView.image = UIImage(named: "music_note_empty_120pt")
        }
        self.titleLabel.text = item.title ?? item.url?.lastPathComponent
        
        if Player.shared.state.isPlaying {
            self.playButton.setImage(UIImage(named: "btn_pause_44pt"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(named: "btn_play_44pt"), for: .normal)
        }
    }
}
