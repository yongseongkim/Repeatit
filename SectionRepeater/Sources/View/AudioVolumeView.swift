//
//  AudioVolumeView.swift
//  SectionRepeater
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
    }
    
    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }
}
