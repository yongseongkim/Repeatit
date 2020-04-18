//
//  WaveformExtractor.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/24.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import AVFoundation
import Accelerate
import UIKit

enum WaveformBarStyle {
    case up
    case down
    case upDown
}

class WaveformExtractor {

    struct SampleDrawingInfo {
        let width: Int
        let interval: Int
        let maxHeight: Int
        let color: UIColor
        let barStyle: WaveformBarStyle
    }

    func loadSamples(url: URL) throws -> [Float] {
        guard let file = try? AVAudioFile(forReading: url),
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                       sampleRate: file.fileFormat.sampleRate,
                                       channels: file.fileFormat.channelCount,
                                       interleaved: false),
            let buf = AVAudioPCMBuffer(pcmFormat: format,
                                       frameCapacity: UInt32(file.length)) else { return [Float]() }
        try file.read(into: buf)
        return Array(UnsafeBufferPointer(start: buf.floatChannelData?[0], count:Int(buf.frameLength)))
    }

    // unit = 3000, 14.7 samples per second
    func downSamples(_ samples: [Float], unit: Int) -> [Float] {
        var processingBuffer = [Float](repeating: 0.0, count: Int(samples.count))
        let numberOfSamples = vDSP_Length(samples.count)
        vDSP_vabs(samples, 1, &processingBuffer, 1, numberOfSamples);
        let filter = [Float](repeating: 1.0 / Float(unit), count: unit)
        let numberOfDownSamples = Int(samples.count / unit)
        var downSamples = [Float](repeating:0.0, count: numberOfDownSamples)
        vDSP_desamp(processingBuffer,
                    vDSP_Stride(unit),
                    filter,
                    &downSamples,
                    vDSP_Length(numberOfDownSamples),
                    vDSP_Length(unit))
        return downSamples
    }

    func createImage(samples: [Float], sample: SampleDrawingInfo) -> UIImage? {
        let numberOfSamples = samples.count
        let width: CGFloat = CGFloat(numberOfSamples * sample.width + (numberOfSamples - 1) * sample.interval)
        let height: CGFloat = CGFloat(sample.maxHeight)
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(sample.width))

        let centerY: CGFloat
        switch sample.barStyle {
        case .up:
            centerY = height
        case .down:
            centerY = 0
        case .upDown:
            centerY = height / 2
        }
        var x: CGFloat = 0
        for idx in 0..<samples.count {
            let sampleHeight: CGFloat = max(min(CGFloat(samples[idx]) * 100, CGFloat(sample.maxHeight)), 1)
            context?.move(to: CGPoint(x: x, y: centerY - sampleHeight))
            context?.addLine(to: CGPoint(x: x, y: centerY + sampleHeight))
            context?.setStrokeColor(sample.color.cgColor)
            context?.strokePath()
            x = x + CGFloat(sample.width) + CGFloat(sample.interval)
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
