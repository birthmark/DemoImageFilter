//
//  CSViewVideoDuration.m
//  ImageFilterDemo
//
//  Created by Chris Hu on 16/8/3.
//  Copyright © 2016年 icetime17. All rights reserved.
//

#import "CSViewVideoDuration.h"

@implementation CSViewVideoDuration {

    NSInteger videoDuration;
    
    NSTimer *videoTimer;
    
    UILabel *durationHour;
    UILabel *durationMin;
    UILabel *durationSec;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (void)prepareUI {
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0.5f;
    
    durationHour = [[UILabel alloc] initWithFrame:self.bounds];
    durationHour.textColor = [UIColor whiteColor];
    durationHour.text = @"00:00:00";
    durationHour.textAlignment = NSTextAlignmentCenter;
    [self addSubview:durationHour];
}

#pragma mark - video capture control

- (void)startVideoCapture {
    videoDuration = 0;
    
    videoTimer = [NSTimer timerWithTimeInterval:1.0f target:self selector:@selector(actionVideoTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:videoTimer forMode:NSRunLoopCommonModes];
}

- (void)stopVideoCapture {
    [videoTimer invalidate];
    videoTimer = nil;
}

- (void)actionVideoTimer:(NSTimer *)sender {
    videoDuration++;
    if (videoDuration > MAX_VIDEO_DURATION) {
        return;
    }
    
    NSLog(@"videoDuration : %ld", (long)videoDuration);
    [self updateVideoDuration:videoDuration];
}

- (void)updateVideoDuration:(NSInteger)duration {
    NSInteger h = duration / 3600;
    NSInteger m = duration % 3600 / 60;
    NSInteger s = duration % 60;
    
    durationHour.text = [NSString stringWithFormat:@"%@:%@:%@", [self stringFormatForInteger:h], [self stringFormatForInteger:m], [self stringFormatForInteger:s]];
}

- (NSString *)stringFormatForInteger:(NSInteger)i {
    NSString *ret;
    
    if (i < 10) {
        ret = [NSString stringWithFormat:@"0%ld", (long)i];
    } else {
        ret = [NSString stringWithFormat:@"%ld", (long)i];
    }
    
    return ret;
}

@end
