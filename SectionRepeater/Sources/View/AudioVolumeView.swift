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
    
    override func volumeSliderRect(forBounds bounds: CGRect) -> CGRect {
        return self.bounds
    }

}
