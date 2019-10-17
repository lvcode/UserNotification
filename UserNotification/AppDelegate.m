//
//  AppDelegate.m
//  UserNotification
//
//  Created by Lv Qiang on 2019/10/8.
//  Copyright © 2019 Lv Qiang. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <YTKNetwork.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    config.baseUrl = @"https://www.apiopen.top";
    [[UIApplication sharedApplication]registerForRemoteNotifications];
    
//    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    window.backgroundColor = [UIColor whiteColor];
//    self.window = window;
//    ViewController *controller = [ViewController new];
//    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:controller];
//    self.window.rootViewController = nav;
//    
//    [self.window makeKeyAndVisible];
    
    return YES;
}


- (void)replyPushNotificationAutorization:(UIApplication *)application {
    if (@available( iOS 10, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                // 用户点击允许
                NSLog(@"授权成功");
            }else {
                //用户点击不允许
                NSLog(@"授权失败");
            }
        }];
        
        //获取授权信息
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"========%@",settings);
            [[UIApplication sharedApplication]registerForRemoteNotifications];
        }];
        
    
    }else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    // 注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

// 获取devicetoken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if (![deviceToken isKindOfClass:[NSData class]]) return;
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    NSLog(@"deviceToken = %@",hexToken);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"%@",error);
}


// ios 10 前台接收消息通知
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    //收到推送的请求
       UNNotificationRequest *request = notification.request;

       //收到推送的内容
       UNNotificationContent *content = request.content;

       //收到用户的基本信息
       NSDictionary *userInfo = content.userInfo;

       //收到推送消息的角标
       NSNumber *badge = content.badge;

       //收到推送消息body
       NSString *body = content.body;

       //推送消息的声音
       UNNotificationSound *sound = content.sound;

       // 推送消息的副标题
       NSString *subtitle = content.subtitle;

       // 推送消息的标题
       NSString *title = content.title;

       if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
           //此处省略一万行需求代码。。。。。。
           NSLog(@"iOS10 收到远程通知:%@",userInfo);

       }else {
           // 判断为本地通知
           NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
       }


       // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
       completionHandler(UNNotificationPresentationOptionBadge |
                         UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
    
}
#pragma mark - 处理后台点击通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;

    //收到推送的内容
    UNNotificationContent *content = request.content;

    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;

    //收到推送消息的角标
    NSNumber *badge = content.badge;

    //收到推送消息body
    NSString *body = content.body;

    //推送消息的声音
    UNNotificationSound *sound = content.sound;

    // 推送消息的副标题
    NSString *subtitle = content.subtitle;

    // 推送消息的标题
    NSString *title = content.title;

    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        //此处省略一万行需求代码。。。。。。

    }else {
        // 判断为本地通知
        //此处省略一万行需求代码。。。。。。
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    
    NSString *webVideoPath;
    if ([userInfo.allKeys containsObject:@"video"]) {
        webVideoPath = [userInfo objectForKey:@"video"];
        NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
//        AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:webVideoUrl];
//        AVPlayerViewController *avPlayerVC =[[AVPlayerViewController alloc] init];
//        avPlayerVC.player = avPlayer;
        
        MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc]initWithContentURL:webVideoUrl];

//        [playerVC.view setFrame:[UIScreen mainScreen].bounds];
//        [playerVC play];
    
        [self.window.rootViewController presentViewController:playerVC animated:YES completion:^{
            
        }];
    }
    
    completionHandler(); // 系统要求执行这个方法
}
#endif

#pragma mark -iOS 10之前收到通知

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"iOS7及以上系统，收到通知:%@", userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
    
}

#pragma mark - UISceneSession lifecycle


//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}


//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
