//
//  XYVideoPlayer.m
//  NotificationExtension
//
//  Created by Lv Qiang on 2019/10/10.
//  Copyright © 2019 Lv Qiang. All rights reserved.
//

#import "LVAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation LVAVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
