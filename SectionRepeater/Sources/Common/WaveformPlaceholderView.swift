//
//  WaveformPlaceholderView.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 7. 30..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit

class WaveformPlaceholderView: UIView {
    static let layerRadius: CGFloat = 22
    
    fileprivate let loadingLayer = CAShapeLayer().then { (layer) in
        layer.contentsScale = UIScreen.main.scale
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.gray220.cgColor
        layer.lineWidth = 4
        layer.lineCap = kCALineJoinBevel
        layer.lineJoin = kCALineJoinBevel;
        layer.path = UIBezierPath.init(arcCenter: CGPoint(x: layerRadius, y: layerRadius),
                                       radius: layerRadius,
                                       startAngle: CGFloat(-Double.pi/2),
                                       endAngle: CGFloat(Double.pi * 3/2), clockwise: true).cgPath
        layer.strokeEnd = 0.75
    }
    fileprivate let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z").then { (anim) in
        anim.toValue = Double.pi * 2
        anim.isCumulative = true;
        anim.duration = 1
        anim.repeatCount = Float.infinity
    }
    
    init() {
        super.init(frame: .zero)
        self.layer.addSublayer(self.loadingLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.loadingLayer.frame = CGRect(x: self.bounds.width / 2 - WaveformPlaceholderView.layerRadius,
                                         y: self.bounds.height / 2 - WaveformPlaceholderView.layerRadius,
                                         width: WaveformPlaceholderView.layerRadius * 2,
                                         height: WaveformPlaceholderView.layerRadius * 2)
        if (self.loadingLayer.animationKeys() == nil) {
            self.loadingLayer.add(self.rotateAnimation, forKey: "rotation")
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
