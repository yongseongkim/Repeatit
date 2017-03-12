//
//  AudioWaveformView.m
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 26..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

#import "AudioWaveformView.h"
@import AudioKit;

@interface AudioWaveformView()

@property (strong, nonatomic) EZAudioPlot *plot;
@property (strong, nonatomic) EZAudioFile *file;

@end

@implementation AudioWaveformView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.plot = [[EZAudioPlot alloc] initWithFrame:self.bounds];
        self.plot.plotType = EZPlotTypeBuffer;
        self.plot.shouldFill = YES;
        self.plot.shouldMirror = YES;
        self.plot.color = [UIColor blueColor];
        [self addSubview:self.plot];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.plot setFrame:self.bounds];
}

- (void)setPath:(NSString *)path {
    if ([_path isEqualToString:path]) {
        return;
    }
    _path = path;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    __weak typeof(self) weakSelf = self;
    if (self.path) {
        self.file = [EZAudioFile audioFileWithURL:[NSURL fileURLWithPath:self.path]];
        self.plot.plotType = EZPlotTypeBuffer;
        self.plot.shouldFill = YES;
        self.plot.shouldMirror = YES;
        [self.file getWaveformDataWithCompletionBlock:^(float **waveformData, int length) {
            [weakSelf.plot updateBuffer:waveformData[0] withBufferSize:length];
        }];
    }
}

@end
