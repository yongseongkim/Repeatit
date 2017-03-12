//
//  AudioWaveformView.h
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 26..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AudioKit;

@interface AudioWaveformView : UIView

@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) UIColor *waveformColor;

@end
