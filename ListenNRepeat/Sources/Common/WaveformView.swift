//
//  WaveformView.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 6. 4..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import AVFoundation
import Accelerate
import SwiftyImage

protocol WaveformViewDelegate {
    func waveformViewDidScroll(scrollView: UIScrollView)
    func waveformViewWillBeginDragging(scrollView: UIScrollView)
    func waveformViewDidEndDragging(_ scrollView: UIScrollView, decelerate: Bool)
    func waveformViewDidEndDecelerating(scrollView: UIScrollView)
}

class WaveformView: UIView {
    static let sampleWidth: CGFloat = 2.0
    static let gapBetweenSamples: CGFloat = 1.0
    static let samplesPerPixel: Int = 3000  // 14.7 samples per second
    static let progressBackgroundColor = UIColor.gray220
    static let progressColor = UIColor.black
    
    public var delegate: WaveformViewDelegate?
    public var url: URL?
    fileprivate var duration: Double = 0
    fileprivate let scrollView = UIScrollView(frame: .zero).then { (scrollView) in
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.white
    }
    fileprivate let progressBackgroundView = UIImageView().then { (imageView) in
        imageView.backgroundColor = UIColor.clear
    }
    fileprivate let progressView = UIView().then { (view) in
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
    }
    fileprivate let progressImageView: UIImageView = UIImageView().then { (imageView) in
        imageView.backgroundColor = UIColor.clear
    }
    fileprivate let placeholderView = WaveformPlaceholderView()
    fileprivate var bookmarkViews = [UIView]()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        self.addSubview(self.placeholderView)
        self.placeholderView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        self.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self)
        }
        self.scrollView.delegate = self
        self.scrollView.addSubview(self.progressBackgroundView)
        self.progressBackgroundView.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.scrollView)
            make.width.equalTo(UIScreen.mainWidth)
            make.height.equalTo(self.scrollView.snp.height)
        }
        self.progressView.addSubview(self.progressImageView)
        self.progressImageView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(self.progressView)
            make.width.equalTo(0)
            make.height.equalTo(self.progressView.snp.height)
        }
        self.scrollView.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(self.scrollView)
            make.width.equalTo(0)
            make.height.equalTo(self.scrollView.snp.height)
        }
    }
    
    public func loadWaveform(url: URL) {
        // clean
        self.url = url
        self.duration = CMTimeGetSeconds(AVURLAsset(url: url).duration)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: self.bounds.width / 2, bottom: 0, right: self.bounds.width / 2)
        
        let preContentWidth = CGFloat(duration * 44.08)
        self.scrollView.isHidden = true
        self.scrollView.contentSize = CGSize(width: preContentWidth, height: self.bounds.height)
        self.progressBackgroundView.snp.updateConstraints({ (make) in
            make.width.equalTo(preContentWidth)
        })
        
        // add waveform
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            do {
                let samples = try weakSelf.loadSamples(url: url)
                let imageSize = CGSize(width: WaveformView.sampleWidth * CGFloat(samples.count) + WaveformView.gapBetweenSamples * CGFloat(samples.count - 1), height: weakSelf.bounds.height)
                if let image = weakSelf.graphImage(samples: samples, imageSize: imageSize, color: WaveformView.progressBackgroundColor) {
                    DispatchQueue.main.async {
                        if weakSelf.url?.absoluteString != url.absoluteString {
                            return
                        }
                        weakSelf.progressBackgroundView.image = image
                        weakSelf.progressBackgroundView.snp.updateConstraints({ (make) in
                            make.width.equalTo(imageSize.width)
                        })
                        weakSelf.progressImageView.image = image.with(color: WaveformView.progressColor)
                        weakSelf.progressImageView.snp.updateConstraints({ (make) in
                            make.width.equalTo(imageSize.width)
                        })
                        weakSelf.scrollView.contentSize = CGSize(width: imageSize.width, height: weakSelf.bounds.height)
                        weakSelf.scrollView.isHidden = false
                        weakSelf.loadBookmarks()
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    public func loadWaveform(url: URL, completion: ((_ loadURL: URL) -> ())?) {
        // clean
        self.url = url
        self.duration = CMTimeGetSeconds(AVURLAsset(url: url).duration)
        self.scrollView.contentInset = UIEdgeInsets(top: 0, left: self.bounds.width / 2, bottom: 0, right: self.bounds.width / 2)
        
        let preContentWidth = CGFloat(duration * 44.08)
        self.scrollView.isHidden = true
        self.scrollView.contentSize = CGSize(width: preContentWidth, height: self.bounds.height)
        self.progressBackgroundView.snp.updateConstraints({ (make) in
            make.width.equalTo(preContentWidth)
        })
        
        // add waveform
        DispatchQueue.global().async { [weak self] in
            guard let weakSelf = self else { return }
            do {
                let samples = try weakSelf.loadSamples(url: url)
                let imageSize = CGSize(width: WaveformView.sampleWidth * CGFloat(samples.count) + WaveformView.gapBetweenSamples * CGFloat(samples.count - 1), height: weakSelf.bounds.height)
                if let image = weakSelf.graphImage(samples: samples, imageSize: imageSize, color: WaveformView.progressBackgroundColor) {
                    DispatchQueue.main.async {
                        if weakSelf.url?.absoluteString != url.absoluteString {
                            return
                        }
                        weakSelf.progressBackgroundView.image = image
                        weakSelf.progressBackgroundView.snp.updateConstraints({ (make) in
                            make.width.equalTo(imageSize.width)
                        })
                        weakSelf.progressImageView.image = image.with(color: WaveformView.progressColor)
                        weakSelf.progressImageView.snp.updateConstraints({ (make) in
                            make.width.equalTo(imageSize.width)
                        })
                        weakSelf.scrollView.contentSize = CGSize(width: imageSize.width, height: weakSelf.bounds.height)
                        weakSelf.scrollView.isHidden = false
                        weakSelf.loadBookmarks()
                        completion?(url)
                    }
                }
            } catch let error {
                print(error)
            }
        }
    }
    
    public func move(progress: Double) {
        self.scrollView.contentOffset = CGPoint(x: (CGFloat(progress) * self.scrollView.contentSize.width) - self.scrollView.contentInset.left, y: 0)
    }
    
    public func loadBookmarks() {
        self.bookmarkViews.forEach({ (view) in
            return view.removeFromSuperview()
        })
        self.bookmarkViews = [UIView]()
        for time in Player.shared.bookmarkTimes {
            let ratio = CGFloat(time / self.duration)
            let contentSize = self.scrollView.contentSize
            let view = UIView(frame: CGRect(x: contentSize.width * ratio - 1, y: 0, width: 2, height: contentSize.height))
            view.backgroundColor = UIColor.directoireBlue
            self.scrollView.addSubview(view)
            self.bookmarkViews.append(view)
        }
    }
    
    fileprivate func loadSamples(url: URL?) throws -> [Float] {
        guard let url = url else { return [Float]() }
        let file = try AVAudioFile(forReading: url)
        let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                   sampleRate: file.fileFormat.sampleRate,
                                   channels: file.fileFormat.channelCount,
                                   interleaved: false)
        let buf = AVAudioPCMBuffer(pcmFormat: format,
                                   frameCapacity: UInt32(file.length))
        try file.read(into: buf)
        let samples = Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
        let downSamplesResult = self.downSamples(samples)
        return downSamplesResult
    }
    
    // sound cloud 1.5초 그래프 한칸당
    fileprivate func downSamples(_ samples: [Float]) -> [Float] {
        var processingBuffer = [Float](repeating: 0.0, count: Int(samples.count))
        let samplesCount = vDSP_Length(samples.count)
        vDSP_vabs(samples, 1, &processingBuffer, 1, samplesCount);
        let filter = [Float](repeating: 1.0 / Float(WaveformView.samplesPerPixel),
                             count: Int(WaveformView.samplesPerPixel))
        let downSamplesCount = Int(samples.count / WaveformView.samplesPerPixel)
        var result = [Float](repeating:0.0,
                                      count:downSamplesCount)
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(WaveformView.samplesPerPixel),
                    filter,
                    &result,
                    vDSP_Length(downSamplesCount),
                    vDSP_Length(WaveformView.samplesPerPixel))
        return result
    }
    
    fileprivate func graphImage(samples: [Float], imageSize: CGSize, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContext(imageSize);
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(WaveformView.sampleWidth)
        let centerY = imageSize.height / 2
        var x:CGFloat = 0
        for idx in 0..<samples.count {
            var sampleWidth: CGFloat = CGFloat(samples[idx]) * 100
            if (sampleWidth < 1) {
                sampleWidth = 1
            }
            context?.move(to: CGPoint(x: x, y: centerY - sampleWidth))
            context?.addLine(to: CGPoint(x: x, y: centerY + sampleWidth))
            context?.setStrokeColor(color.cgColor)
            context?.strokePath()
            x = x + WaveformView.sampleWidth + WaveformView.gapBetweenSamples
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension WaveformView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.progressView.snp.updateConstraints({ (make) in
            make.width.equalTo(scrollView.contentOffset.x + self.scrollView.contentInset.left)
        })
        self.scrollView.layoutIfNeeded()
        self.delegate?.waveformViewDidScroll(scrollView: scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.delegate?.waveformViewWillBeginDragging(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delegate?.waveformViewDidEndDragging(scrollView, decelerate: decelerate)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.delegate?.waveformViewDidEndDecelerating(scrollView: scrollView)
    }
}
