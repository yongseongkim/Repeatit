//
//  WaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/24.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import SnapKit
import SwiftUI
import UIKit

class WaveformView: UIView {
    enum WaveformError: Error {
        case failToLoadSamples
    }

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

    var progressChangedByDraggingPublisher: AnyPublisher<Double, Never> {
        let initialResultValue = isDraggingSubject.value
        return isDraggingSubject
            .scan((initialResultValue, initialResultValue), { ($0.1, $1) })
            .filter { $0.0 && !$0.1 }
            .compactMap { [weak self] _ -> Double? in
                guard let self = self else { return nil }
                return self.progress
            }
            .eraseToAnyPublisher()
    }

    var isDraggingPublisher: AnyPublisher<Bool, Never> {
        return isDraggingSubject.eraseToAnyPublisher()
    }

    private let audioPlayer: AudioPlayer
    private let extractor = WaveformExtractor()
    private var cacheWaveform: (url: URL, image: UIImage?)?
    private let isDraggingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables: [AnyCancellable] = []
    private var waveformCancellable: AnyCancellable?

    // MARK: - UI Components
    private let scrollView = UIScrollView().apply {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = .fast
        $0.backgroundColor = .systemWhite
    }
    private let waveformImageView = UIImageView()
    // MARK: -

    init(audioPlayer: AudioPlayer) {
        self.audioPlayer = audioPlayer
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func loadWaveform(url: URL) {
        waveformCancellable = loadWaveform(url: url, maxHeight: bounds.height)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    guard let self = self, let image = image else { return }
                    self.waveformImageView.image = image
                    self.waveformImageView.snp.updateConstraints { make in
                        make.width.equalTo(image.size.width)
                        make.height.equalTo(image.size.height)
                        make.leading.trailing.equalToSuperview().inset(self.bounds.size.width / 2)
                    }
                }
        )
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

        cancellables += [
            isDraggingPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] isDragging in
                    isDragging ? self?.audioPlayer.pause() : self?.audioPlayer.resume()
                }
        ]

        cancellables += [
            progressChangedByDraggingPublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] progress in
                                    guard let self = self else { return }
                    self.audioPlayer.move(to: self.audioPlayer.duration * progress)
                }
        ]

        cancellables += [
            audioPlayer.currentPlayTimePublisher
                .receive(on: RunLoop.main)
                .sink { [weak self] currentTime in
                    guard let self = self else { return }
                    self.progress = self.audioPlayer.duration != 0 ? currentTime / self.audioPlayer.duration : 1
            }
        ]
    }

    private func loadWaveform(url: URL, maxHeight: CGFloat) -> Future<UIImage?, WaveformError> {
        return Future<UIImage?, WaveformError> { [weak self] promise in
            guard let self = self else { promise(.success(nil)); return }
            if let cache = self.cacheWaveform, cache.url == url, let image = cache.image, image.size.height == maxHeight {
                promise(.success(image))
            }
            DispatchQueue.global().async {
                if let samples = try? self.extractor.loadSamples(url: url) {
                    let downSamples = self.extractor.downSamples(samples, unit: 3000)
                    promise(.success(
                        self.extractor.createImage(
                            samples: downSamples,
                            sample: .init(
                                width: 2,
                                interval: 1,
                                maxHeight: Int(maxHeight),
                                color: .systemBlack)
                    )))
                } else {
                    promise(.failure(.failToLoadSamples))
                }
            }

        }
    }
}

extension WaveformView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDraggingSubject.send(true)
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            isDraggingSubject.send(false)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isDraggingSubject.send(false)
    }
}

struct WaveformViewUI: UIViewRepresentable {
    let url: URL
    let audioPlayer: AudioPlayer

    func makeUIView(context: Context) -> WaveformView {
        return WaveformView(audioPlayer: audioPlayer)
    }

    func updateUIView(_ uiView: WaveformView, context: Context) {
        uiView.loadWaveform(url: url)
    }
}
