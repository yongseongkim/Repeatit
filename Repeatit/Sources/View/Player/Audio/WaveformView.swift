//
//  WaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/24.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import ComposableArchitecture
import PinLayout
import SwiftUI
import UIKit

class WaveformView: UIView {
    static let verticalPadding: CGFloat = 10

    var isDraggingPublisher: AnyPublisher<Bool, Never> {
        return isDraggingSubject.removeDuplicates().eraseToAnyPublisher()
    }

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

    private let isDraggingSubject = CurrentValueSubject<Bool, Never>(false)
    private var cancellables: [AnyCancellable] = []

    let viewStore: ViewStore<AudioPlayerState, AudioPlayerAction>
    let waveformOption: WaveformBarOption

    init(store: Store<AudioPlayerState, AudioPlayerAction>, waveformOption: WaveformBarOption) {
        self.viewStore = ViewStore(store)
        self.waveformOption = waveformOption
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        viewStore.send(.loadWaveform(waveformOption))
        layout()
    }
}

extension WaveformView {
    private func initialize() {
        scrollView.delegate = self
        addSubview(scrollView)
        scrollView.addSubview(waveformImageView)
        progressedWaveformContainer.addSubview(progressedWaveformImageView)
        scrollView.addSubview(progressedWaveformContainer)

        // Bind State
        viewStore.publisher
            .compactMap { $0.waveformImage }
            .sink(receiveValue: { [weak self] waveformImage in
                self?.waveformImageView.image = waveformImage.withTintColor(.systemBlack)
                self?.progressedWaveformImageView.image = waveformImage.withTintColor(.classicBlue)
                self?.layout()
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(
            viewStore.publisher
                .map { $0.duration }
                .removeDuplicates(),
            viewStore.publisher
                .map { $0.playTime }
                .removeDuplicates()
        )
        .map { duration, playTime in duration == 0 ? 0 : playTime / duration }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] progress in
            guard let self = self, let contentWidth = self.waveformImageView.image?.size.width else { return }
            self.scrollView.setContentOffset(
                CGPoint(x: contentWidth * CGFloat(progress), y: self.scrollView.contentOffset.y),
                animated: false
            )
        }
        .store(in: &cancellables)

        // Bind Actions
        let beginDragging = isDraggingPublisher.filter { $0 }
        let endDragging = isDraggingPublisher.filter { !$0 }
        beginDragging
            .compactMap { [weak self] _ in self?.viewStore.isPlaying }
            .handleEvents(receiveOutput: { [weak self] _ in
                // When dragging begins, pause the player.
                self?.viewStore.send(.pause)
            })
            .flatMap { isPlaying -> AnyPublisher<Bool, Never> in
                return endDragging
                    .map { _ in isPlaying }
                    .first()
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] wasPlayingBeforeDragging in
                guard let self = self else { return }
                let contentOffsetX = self.scrollView.contentOffset.x
                let contentWidth = self.waveformImageView.image?.size.width ?? 0
                let progress = Double(contentOffsetX / contentWidth)
                let targetSeconds = self.viewStore.duration * progress
                self.viewStore.send(.move(to: targetSeconds))
                if wasPlayingBeforeDragging {
                    self.viewStore.send(.resume)
                }
            }
            .store(in: &cancellables)
    }

    private func layout() {
        var imageSize: CGSize = .zero
        if let waveformImage = viewStore.state.waveformImage {
            imageSize = waveformImage.size
        }
        scrollView.pin.all()
        waveformImageView.pin.vertically(WaveformView.verticalPadding).horizontally(bounds.width / 2).width(imageSize.width).height(imageSize.height)
        scrollView.contentSize = CGSize(width: waveformImageView.bounds.size.width + bounds.width, height: bounds.height)

        layoutProgressedWaveform()
    }

    private func layoutProgressedWaveform() {
        let imageSize = waveformImageView.frame.size
        progressedWaveformImageView.pin.vertically().left().width(imageSize.width).height(imageSize.height)
        progressedWaveformContainer.pin.left(to: waveformImageView.edge.left).top(to: waveformImageView.edge.top).width(scrollView.contentOffset.x).height(imageSize.height)
    }
}

extension WaveformView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutProgressedWaveform()
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
    let store: Store<AudioPlayerState, AudioPlayerAction>
    let waveformOption: WaveformBarOption

    func makeUIView(context: Context) -> WaveformView {
        return WaveformView(store: store, waveformOption: waveformOption)
    }

    func updateUIView(_ uiView: WaveformView, context: Context) {
    }
}
