//
//  WaveformClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Accelerate
import AVFoundation
import ComposableArchitecture
import UIKit

struct WaveformBarOption: Equatable, CustomStringConvertible {
    enum Style: String {
        case up
        case down
        case upDown
    }

    let width: Int
    let interval: Int
    let maxHeight: Int
    let style: Style

    var description: String {
        return "width: \(width), interval: \(interval), maxHeight: \(maxHeight), style: \(style)"
    }
}

struct WaveformClient {
    let loadWaveform: (URL, WaveformBarOption) -> Effect<UIImage, Failure>

    enum Failure: Error, Equatable {
        case couldntLoadWaveform
    }
}

extension WaveformClient {
    struct WaveformDependencyID: Hashable {}

    static let production = WaveformClient(
        loadWaveform: { url, option in
            return .future { callback in
                let dependency = dependencies[WaveformDependencyID()] ?? WaveformClientDependencies()
                dependency.loadWaveform(url: url, option: option) { image, error in
                    if let image = image {
                        callback(.success(image))
                        return
                    }
                    callback(.failure(.couldntLoadWaveform))
                }
                dependencies[WaveformDependencyID()] = dependency
            }
        }
    )
}

private var dependencies: [AnyHashable: WaveformClientDependencies] = [:]

private class WaveformClientDependencies: NSObject {
    var images: [String: UIImage] = [:]

    func loadWaveform(
        url: URL,
        option: WaveformBarOption,
        processQueue: DispatchQueue = DispatchQueue.global(),
        useCache: Bool = true,
        completion: @escaping (UIImage?, Error?) -> Void
    ) {
        let key = cacheKey(url: url, option: option)
        if useCache {
            if let cache = images[key] {
                completion(cache, nil)
                return
            }
        }
        processQueue.async { [weak self] in
            do {
                let samples = try self?.loadSamples(url: url) ?? []
                let downSamples = self?.down(samples: samples, unit: 3000) ?? []
                let waveformImage = self?.createImage(samples: downSamples, option: option)
                self?.images[key] = waveformImage
                completion(waveformImage, nil)
            } catch let error {
                completion(nil, error)
            }
        }
    }

    private func cacheKey(url: URL, option: WaveformBarOption) -> String {
        return "\(url.absoluteString)-\(option.description)"
    }
}

extension WaveformClientDependencies {
    private func loadSamples(url: URL) throws -> [Float] {
        guard let file = try? AVAudioFile(forReading: url),
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                       sampleRate: file.fileFormat.sampleRate,
                                       channels: file.fileFormat.channelCount,
                                       interleaved: false),
            let buf = AVAudioPCMBuffer(pcmFormat: format,
                                       frameCapacity: UInt32(file.length)) else { return [Float]() }
        try file.read(into: buf)
        return Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count: Int(buf.frameLength)))
    }

    // unit = 3000, 14.7 samples per second
    private func down(samples: [Float], unit: Int) -> [Float] {
        var processingBuffer = [Float](repeating: 0.0, count: Int(samples.count))
        let numberOfSamples = vDSP_Length(samples.count)
        vDSP_vabs(samples, 1, &processingBuffer, 1, numberOfSamples)
        let filter = [Float](repeating: 1.0 / Float(unit), count: unit)
        let numberOfDownSamples = Int(samples.count / unit)
        var downSamples = [Float](repeating: 0.0, count: numberOfDownSamples)
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(unit),
                    filter,
                    &downSamples,
                    vDSP_Length(numberOfDownSamples),
                    vDSP_Length(unit))
        return downSamples
    }

    private func createImage(samples: [Float], option: WaveformBarOption) -> UIImage? {
        let numberOfSamples = samples.count
        let width: CGFloat = CGFloat(numberOfSamples * option.width + (numberOfSamples - 1) * option.interval)
        let height: CGFloat = CGFloat(option.maxHeight)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(option.width))

        let centerY: CGFloat
        switch option.style {
        case .up:
            centerY = height
        case .down:
            centerY = 0
        case .upDown:
            centerY = height / 2
        }
        var x: CGFloat = 0
        for idx in 0..<samples.count {
            let sampleHeight: CGFloat = max(min(CGFloat(samples[idx]) * 100, CGFloat(option.maxHeight / 2)), 1)
            context?.move(to: CGPoint(x: x, y: centerY - sampleHeight))
            context?.addLine(to: CGPoint(x: x, y: centerY + sampleHeight))
            context?.setStrokeColor(UIColor.white.cgColor)
            context?.strokePath()
            x += CGFloat(option.width) + CGFloat(option.interval)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
