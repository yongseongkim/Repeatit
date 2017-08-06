//
//  AudioVolumeView.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 3. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import MediaPlayer

class AudioVolumeView: MPVolumeView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        for view in self.subviews {
            if let airplayButton = view as? UIButton {
                airplayButton.isHidden = true
            }
        }
        self.setVolumeThumbImage(UIImage.size(width: 3, height: 16).color(UIColor.black).image, for: .normal)
        self.setMinimumVolumeSliderImage(UIImage.size(width: self.bounds.width, height: 3).color(UIColor.black).image, for: .normal)
        self.setMaximumVolumeSliderImage(UIImage.size(width: self.bounds.width, height: 3).color(UIColor.gray220).image, for: .normal)
    }
    
    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
}
