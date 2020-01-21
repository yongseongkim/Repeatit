//
//  WaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/24.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import UIKit
import SwiftUI
import SnapKit
import RxSwift
import RxCocoa

enum WaveformError: Error {
    case failToLoadSamples
}

class WaveformView: UIView {
    var progress: Double {
        get {
            guard let contentWidth = self.waveformImageView.image?.size.width else { return 0 }
            return Double(scrollView.contentOffset.x / contentWidth)
        }
        set {
            guard let contentWidth = self.waveformImageView.image?.size.width else { return }
            scrollView.setContentOffset(CGPoint(x: contentWidth * CGFloat(newValue), y: scrollView.contentOffset.y), animated: false)
        }
    }

    var progressChangedByDraggingObservable: Observable<Double> {
        return isDraggingRelay
            .withPrevious(startWith: isDraggingRelay.value)
            .filter { $0.0 && !$0.1 }
            .compactMap { [weak self] _ in
                guard let self = self else { return nil }
                return self.progress
            }
    }

    var isDraggingObservable: Observable<Bool> {
        return isDraggingRelay.asObservable()
    }

    func loadWaveform(url: URL) {
        loadWaveform(url: url, maxHeight: bounds.height)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] image in
                guard let self = self, let image = image else { return }
                self.waveformImageView.image = image
                self.waveformImageView.snp.updateConstraints { make in
                    make.width.equalTo(image.size.width)
                    make.height.equalTo(image.size.height)
                    make.leading.trailing.equalToSuperview().inset(self.bounds.size.width / 2)
                }
            })
            .disposed(by: disposeBag)
    }

    private let player: Player
    private let extractor = WaveformExtractor()
    private var cacheWaveform: (url: URL, image: UIImage?)?
    private let isDraggingRelay = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()

    // MARK: - UI Components
    private let scrollView = UIScrollView().apply {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = .fast
        $0.backgroundColor = .systemWhite
    }
    private let waveformImageView = UIImageView()
    // MARK: -

    init(player: Player) {
        self.player = player
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialize() {
        scrollView.addSubview(waveformImageView)
        waveformImageView.snp.makeConstraints { make in
            make.width.height.equalTo(0)
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        addSubview(scrollView)
        scrollView.delegate = self
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        isDraggingObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] isDragging in
                if isDragging {
                    self?.player.pause()
                } else {
                    self?.player.resume()
                }
            })
            .disposed(by: disposeBag)

        progressChangedByDraggingObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] progress in
                guard let self = self else { return }
                self.player.move(to: self.player.duration * progress)
            })
            .disposed(by: disposeBag)

        player.currentPlayTimeObservable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] currentTime in
                guard let self = self else { return }
                self.progress = self.player.duration != 0 ? currentTime / self.player.duration : 1
            })
            .disposed(by: disposeBag)
    }

    private func loadWaveform(url: URL, maxHeight: CGFloat) -> Single<UIImage?> {
        if let cache = cacheWaveform, cache.url == url, let image = cache.image, image.size.height == maxHeight {
            return Single.just(image)
        }
        return Single<UIImage?>.create { [weak self] single -> Disposable in
            guard let self = self else { return Disposables.create() }
            DispatchQueue.global().async {
                if let samples = try? self.extractor.loadSamples(url: url) {
                    let downSamples = self.extractor.downSamples(samples, unit: 3000)
                    let image = self.extractor.createImage(
                        samples: downSamples,
                        sample: .init(
                            width: 2,
                            interval: 1,
                            maxHeight: Int(maxHeight),
                            color: .systemBlack)
                    )
                    self.cacheWaveform = (url: url, image: image)
                    single(.success(image))
                } else {
                    single(.error(WaveformError.failToLoadSamples))
                }
            }
            return Disposables.create()
        }
    }
}

extension WaveformView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDraggingRelay.accept(true)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isDraggingRelay.accept(false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDraggingRelay.accept(false)
    }
}

struct WaveformViewUI: UIViewRepresentable {
    let url: URL
    let player: Player

    func makeUIView(context: Context) -> WaveformView {
        return WaveformView(player: player)
    }

    func updateUIView(_ uiView: WaveformView, context: Context) {
        uiView.loadWaveform(url: url)
    }
}
