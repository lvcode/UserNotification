//
//  NotificationViewController.m
//  NotificationExtension
//
//  Created by Lv Qiang on 2019/10/9.
//  Copyright © 2019 Lv Qiang. All rights reserved.
//



#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <YTKNetwork.h>
#import "NewsApi.h"
#import <AVFoundation/AVFoundation.h>
#import "LVAVPlayerView.h"

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (weak, nonatomic) IBOutlet LVAVPlayerView *videoLayer;
@property (nonatomic, strong) AVPlayerLayer *avLayer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (assign, nonatomic) BOOL isChangeValue;


@property (nonatomic, strong) UNNotification *notification;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    config.baseUrl = @"https://www.apiopen.top";
    
}
- (IBAction)likeAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

#pragma mark - 富媒体按钮

//-(UNNotificationContentExtensionMediaPlayPauseButtonType)mediaPlayPauseButtonType {
//    if ([self.notification.request.content.categoryIdentifier isEqualToString:@"video"]) {
//        return UNNotificationContentExtensionMediaPlayPauseButtonTypeDefault;
//    }else {
//        return UNNotificationContentExtensionMediaPlayPauseButtonTypeNone;
//    }
//}
//
//- (CGRect)mediaPlayPauseButtonFrame {
//    CGPoint center = self.imageView.center;
//    return CGRectMake(center.x - 25, center.y - 25, 50, 50);
//}
//
//- (UIColor *)mediaPlayPauseButtonTintColor {
//    return [UIColor lightGrayColor];
//}

#pragma mark - 接收通知
- (void)didReceiveNotification:(UNNotification *)notification {
    self.notification = notification;
    NSDictionary *dic = notification.request.content.userInfo;
    
    self.label.text = notification.request.content.body;
    if ([notification.request.content.categoryIdentifier isEqualToString:@"textInPut"]) {
        [self.activity startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:@"https://f10.baidu.com/it/u=1033990265,2059392894&fm=72"] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.activity stopAnimating];
        }];
    }else if ([notification.request.content.categoryIdentifier isEqualToString:@"video"]){
        NSString *url;
        if (![dic.allKeys containsObject:@"aps"]) {
            url = [dic objectForKey:@"video"];
        }
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
        self.currentPlayerItem = playerItem;
        self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        self.avLayer = (AVPlayerLayer *)self.videoLayer.layer;
        [self.avLayer setPlayer:self.player];
        self.videoLayer.hidden = NO;
        [self.slider addTarget:self action:@selector(_sliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        
        __weak typeof(self) weakSelf = self;
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            /// 更新播放进度
            [weakSelf updateProgress];
        }];
    }else if ([notification.request.content.categoryIdentifier isEqualToString:@"dynamicAction"]) {
        self.likeBtn.hidden = NO;
        [self.activity startAnimating];
        NSString *url;
        if (![dic.allKeys containsObject:@"aps"]) {
            url = [dic objectForKey:@"image"];
        }
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.activity stopAnimating];
        }];

    }else if ([notification.request.content.categoryIdentifier isEqualToString:@"imageContent"]){
        
        NSLog(@"%s -- %@",__func__,dic);
        NSDictionary *aps = [dic objectForKey:@"aps"];
        self.label.text = [[NSString stringWithFormat:@"%@",dic] stringByRemovingPercentEncoding];
        [self.activity startAnimating];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:[aps objectForKey:@"url"]] placeholderImage:nil options:SDWebImageProgressiveDownload completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            [self.activity stopAnimating];
        }];

    }
}

#pragma mark - 通知回调
-(void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {

    if ([response isKindOfClass:[UNTextInputNotificationAction class]]) {
        //处理提交文本的逻辑
//        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }else if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }else {
        if ([response.actionIdentifier isEqualToString:@"see1"]) {
            //处理按钮3
            [self.activity startAnimating];
            NewsApi *news = [[NewsApi alloc]init];
            [news startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
                NSLog(@"%@",request.responseJSONObject);
                [self.activity stopAnimating];
                completion(UNNotificationContentExtensionResponseOptionDismiss);
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                [self.activity stopAnimating];
                completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
            }];
            
            
            
        }else if ([response.actionIdentifier isEqualToString:@"open"]) {
            [self.player play];
            if (@available(iOS 12.0, *)) {
                UNNotificationAction * score1 = [UNNotificationAction actionWithIdentifier:@"close" title:@"暂停" options:UNNotificationActionOptionDestructive];
                NSMutableArray *array = self.extensionContext.notificationActions.mutableCopy;
                [array removeObject:array.lastObject];
                [array addObject:score1];
                self.extensionContext.notificationActions = array;
            }
        }else if ([response.actionIdentifier isEqualToString:@"close"]) {
            [self.player pause];
            if (@available(iOS 12.0, *)) {
                
                UNNotificationAction * score1 = [UNNotificationAction actionWithIdentifier:@"open" title:@"播放" options:UNNotificationActionOptionDestructive];
                NSMutableArray *array = self.extensionContext.notificationActions.mutableCopy;
                [array removeObject:array.lastObject];
                [array addObject:score1];
                self.extensionContext.notificationActions = array;
            }
        }else if ([response.actionIdentifier isEqualToString:@"score1"]) {
            
            if (@available(iOS 12.0, *)) {
                UNNotificationAction * score1 = [UNNotificationAction actionWithIdentifier:@"score3" title:@"十分满意" options:UNNotificationActionOptionDestructive];
                UNNotificationAction * score2 = [UNNotificationAction actionWithIdentifier:@"score4" title:@"满意" options:UNNotificationActionOptionDestructive];
                UNNotificationAction * score3 = [UNNotificationAction actionWithIdentifier:@"score5" title:@"不满意" options:UNNotificationActionOptionDestructive];
                NSMutableArray *array = self.extensionContext.notificationActions.mutableCopy;
                [array removeObject:array.firstObject];
                [array insertObjects:@[score1,score2,score3] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)]];
                self.extensionContext.notificationActions = array;
            } else {
        
            }
        }else if ([response.actionIdentifier isEqualToString:@"openApp"]) {
            completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
        }
        else {
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        }
    }
}

#pragma mark - 视频进度条
- (void)_sliderValueDidChanged:(UISlider *)slider {
    //拖拽的时候先暂停
    BOOL isPlaying = false;
    if (self.player.rate > 0) {
        isPlaying = true;
        [self.player pause];
    }
    // 先不跟新进度
    self.isChangeValue = true;
    
    float fps = [[[self.player.currentItem.asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] nominalFrameRate];
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds(self.player.currentItem.duration) * self.slider.value, fps);
    __weak typeof(self) weakSelf = self;
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        if (isPlaying) {
            [weakSelf.player play];
        }
        weakSelf.isChangeValue = false;
    }];
}

- (void)updateProgress {
    if (self.isChangeValue) {
        [self.slider setValue:CMTimeGetSeconds(self.player.currentItem.currentTime) / CMTimeGetSeconds(self.player.currentItem.duration) animated:YES];
    }
}

@end
