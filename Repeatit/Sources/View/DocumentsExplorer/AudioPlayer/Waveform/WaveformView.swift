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

enum WaveformError: Error {
    case failToLoadSamples
}

class WaveformView: UIView {
    var progressOfAudio: Double {
        return audioPlayer.playTimeSeconds / audioPlayer.duration
    }

    var ratioOfContentOffset: Double {
        guard let contentWidth = self.waveformImageView.image?.size.width else { return 0 }
        return Double(scrollView.contentOffset.x / contentWidth)
    }

    var progressChangedByDraggingPublisher: AnyPublisher<Double, Never> {
        let initialResultValue = isDraggingSubject.value
        return isDraggingSubject
            .removeDuplicates()
            .scan((initialResultValue, initialResultValue), { ($0.1, $1) })
            .filter { $0.0 && !$0.1 }
            .compactMap { [weak self] _ -> Double? in
                guard let self = self else { return nil }
                return self.ratioOfContentOffset
            }
            .eraseToAnyPublisher()
    }

    var isDraggingPublisher: AnyPublisher<Bool, Never> {
        return isDraggingSubject.removeDuplicates().eraseToAnyPublisher()
    }

    private let audioPlayer: AudioPlayer
    private let url: URL
    private let barStyle: WaveformBarStyle
    private let extractor = WaveformExtractor()
    private let isDraggingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables: [AnyCancellable] = []
    private var waveformCancellable: AnyCancellable?

    // MARK: - UI Components
    private let scrollView = UIScrollView().apply {
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = .fast
        $0.backgroundColor = .clear
    }
    private let waveformImageView = UIImageView()
    private let progressedWaveformContainer = UIView().apply {
        $0.clipsToBounds = true
    }
    private let progressedWaveformImageView = UIImageView()
    // MARK: -

    init(audioPlayer: AudioPlayer, url: URL, barStyle: WaveformBarStyle) {
        self.audioPlayer = audioPlayer
        self.url = url
        self.barStyle = barStyle
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        loadWaveform(with: barStyle)
    }

    func loadWaveform(with barStyle: WaveformBarStyle) {
        waveformCancellable = loadWaveform(url: url, maxHeight: bounds.height, barStyle: barStyle)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] image in
                    guard let self = self, let image = image, image != self.waveformImageView.image else { return }
                    self.waveformImageView.image = image
                    self.waveformImageView.snp.updateConstraints { make in
                        make.width.equalTo(image.size.width)
                        make.height.equalTo(image.size.height)
                        make.leading.trailing.equalToSuperview().inset(self.bounds.size.width / 2)
                    }
                    self.progressedWaveformImageView.image = image.withTintColor(.classicBlue)
                    self.progressedWaveformImageView.snp.updateConstraints { make in
                        make.width.equalTo(image.size.width)
                        make.height.equalTo(image.size.height)
                        make.leading.equalToSuperview().inset(self.bounds.size.width / 2)
                    }
                    self.applyPlayTimeToScrollView(time: self.audioPlayer.playTimeSeconds)
                }
        )
    }

    private func initialize() {
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(waveformImageView)
        waveformImageView.snp.makeConstraints { make in
            make.width.height.equalTo(0)
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        scrollView.addSubview(progressedWaveformContainer)
        progressedWaveformContainer.frame = CGRect.zero
        progressedWaveformContainer.addSubview(progressedWaveformImageView)
        progressedWaveformImageView.snp.makeConstraints { make in
            make.width.height.equalTo(0)
            make.top.leading.equalToSuperview()
        }

        isDraggingPublisher
            .filter { $0 }
            .map { [weak self] _ -> Bool in
                guard let self = self else { return false }
                return self.audioPlayer.isPlaying
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.audioPlayer.pause()
            })
            .map { [weak self] isPlaying -> AnyPublisher<Bool, Never> in
                guard let self = self else { return Empty<Bool, Never>().eraseToAnyPublisher() }
                return self.isDraggingPublisher
                    .filter { !$0 }
                    .map { _ in isPlaying }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .sink { [weak self] isPlaying in
                guard isPlaying else { return }
                self?.audioPlayer.resume()
            }
            .store(in: &cancellables)

        progressChangedByDraggingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                guard let self = self else { return }
                self.audioPlayer.move(to: self.audioPlayer.duration * progress)
            }
            .store(in: &cancellables)

        audioPlayer.playTimePublisher
            // TODO: receive(RunLoop.main)
            .sink { [weak self] in
                self?.applyPlayTimeToScrollView(time: $0)
            }
            .store(in: &cancellables)
    }

    private func loadWaveform(url: URL, maxHeight: CGFloat, barStyle: WaveformBarStyle) -> Future<UIImage?, WaveformError> {
        return Future<UIImage?, WaveformError> { [weak self] promise in
            guard let self = self, maxHeight > 0 else { promise(.success(nil)); return }
            DispatchQueue.main.async {
                let tintColor = self.tintColor!
                if let cache = WaveformCacheManager.shared.get(url: url, barStyle: barStyle, height: maxHeight) {
                    promise(.success(cache.withTintColor(tintColor)))
                }
                DispatchQueue.global().async {
                    if let samples = try? self.extractor.loadSamples(url: url) {
                        let downSamples = self.extractor.downSamples(samples, unit: 3000)
                        let waveformImage = self.extractor.createImage(
                            samples: downSamples,
                            sample: .init(
                                width: 2,
                                interval: 1,
                                maxHeight: Int(maxHeight),
                                color: .red,
                                barStyle: barStyle)
                            )?.apply { WaveformCacheManager.shared.add(url: url, barStyle: barStyle, image: $0) }
                        promise(.success(waveformImage?.withTintColor(tintColor)))
                    } else {
                        promise(.failure(.failToLoadSamples))
                    }
                }
            }
        }
    }

    private func applyPlayTimeToScrollView(time: Double) {
        guard let contentWidth = self.waveformImageView.image?.size.width else { return }
        let progress = audioPlayer.duration != 0 ? time / self.audioPlayer.duration : 1
        DispatchQueue.main.async {
            self.scrollView.setContentOffset(CGPoint(x: contentWidth * CGFloat(progress), y: self.scrollView.contentOffset.y), animated: false)
        }
    }
}

extension WaveformView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        progressedWaveformContainer.frame = CGRect(x: 0, y: 0, width: scrollView.bounds.width / 2 + scrollView.contentOffset.x, height: scrollView.frame.height)
    }

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
    let barStyle: WaveformBarStyle

    func makeUIView(context: Context) -> WaveformView {
        return WaveformView(audioPlayer: audioPlayer, url: url, barStyle: barStyle)
    }

    func updateUIView(_ uiView: WaveformView, context: Context) {
        uiView.loadWaveform(with: barStyle)
    }
}
