//
//  ViewController.m
//  UserNotification
//
//  Created by Lv Qiang on 2019/10/8.
//  Copyright © 2019 Lv Qiang. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <Masonry.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,UNUserNotificationCenterDelegate>

@property (nonatomic, strong) NSMutableArray *titleArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *cellArr;

@end

static NSString *identifier = @"CELL";

@implementation ViewController


-(UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:identifier];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

-(NSMutableArray *)titleArr {
    if (!_titleArr) {
        _titleArr = [[NSMutableArray alloc]initWithObjects:@"注册推送",@"定时推送",@"日历推送",@"位置推送", nil];
    }
    return _titleArr;
}

-(NSMutableArray *)cellArr {
    if (!_cellArr) {
        _cellArr = [[NSMutableArray alloc]initWithObjects:@{@"title":@"仅文字"},@{@"title":@"文字➕小图"},@{@"title":@"通知内容：文本"}, @{@"title":@"通知内容：视频"},@{@"title":@"通知内容：文本+动态交互"},nil];
    }
    return _cellArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"消息通知";
    [self getNotificationStatus];
    [self.tableView reloadData];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(getNotificationStatus)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark - tableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.cellArr.count;
    }else {
        return 1;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return 40;
    }else {
        return 0.01;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.titleArr[section];
    }else {
        return nil;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.section == 1) {
        cell.textLabel.text = [self.cellArr[indexPath.row] objectForKey:@"title"];
    }else {
        cell.textLabel.text = self.titleArr[indexPath.section];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
        {
            [self replyPushNotificationAutorization:[UIApplication sharedApplication]];
        }
            break;
        
        case 1:
        {
            [self locoalTimeIntervalNotificationWithIndex:indexPath];
        }
            break;
            
        case 2:
        {
            [self locoalCalendarNotification];
        }
            break;
        
        case 3:
        {
            [self locoalLocationNotification];
        }
            
        default:
            break;
    }
}

- (void)getNotificationStatus {
    if (@available(iOS 10, *)) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            switch (settings.authorizationStatus) {
                case UNAuthorizationStatusNotDetermined:
                {
                    [self.titleArr replaceObjectAtIndex:0 withObject:@"注册推送"];
                }
                    break;
                case UNAuthorizationStatusDenied:
                {
                    [self.titleArr replaceObjectAtIndex:0 withObject:@"推送权限关闭"];
                }
                    break;
                case UNAuthorizationStatusAuthorized:
                {
                    [self.titleArr replaceObjectAtIndex:0 withObject:@"推送权限已打开"];
                }
                    break;
                    
                default:
                    break;
                    
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark - 注册通知
- (void)replyPushNotificationAutorization:(UIApplication *)application {
    
    if (@available( iOS 10, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = [UIApplication sharedApplication].delegate;
        UNNotificationAction *action = [UNNotificationAction actionWithIdentifier:@"imageContent_Action" title:@"忽略" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive];
        UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"imageContent" actions:@[action] intentIdentifiers:@[action.identifier] options:UNNotificationCategoryOptionCustomDismissAction];
        [center setNotificationCategories:[NSSet setWithObject:comment]];
        
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (!error && granted) {
                // 用户点击允许
                NSLog(@"授权成功");
            }else {
                //用户点击不允许
                NSLog(@"授权失败");
            }
            [self getNotificationStatus];
        }];
        
        
        //获取授权信息
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"========%@",settings);
        }];
    }else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
        
        
        
    }
    // 注册远端消息通知获取device token
    [application registerForRemoteNotifications];
}

// 定时推送
- (void)locoalTimeIntervalNotificationWithIndex:(NSIndexPath *)index {
    // 1、UNTimeIntervalNotificationTrigger 定时任务
    UNTimeIntervalNotificationTrigger *trigger1 = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = [NSString stringWithFormat:@"title: %@",[self.cellArr[index.row] objectForKey:@"title"]];
    content.subtitle = @"subtitle: 副标题";
    content.body = @"body: 通知内容";
    content.badge = @66;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"video":@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4",
                         @"image":@"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=2347991050,492615204&fm=26&gp=0.jp"};
    if (index.row == 2) {
        content.categoryIdentifier = @"textInPut";
    }else if (index.row == 3) {
        content.categoryIdentifier = @"video";
    }else if (index.row == 4) {
        content.categoryIdentifier = @"dynamicAction";
    }
    
    if (index.row == 1 || index.row == 4) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"life" ofType:@"jpg"];
        NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
        options[UNNotificationAttachmentOptionsTypeHintKey] = (__bridge id _Nullable)(kUTTypeImage);
        UNNotificationAttachment *attach = [UNNotificationAttachment attachmentWithIdentifier:@"attachId" URL:[NSURL fileURLWithPath:path] options:nil error:nil];
        content.attachments = @[attach];
    }
    
    NSString *requestIdentifier = @"First";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger1];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[self catageryIdentifierWithIndex:index]];
    
    /*
     需要解锁显示，红色文字。点击不会进app。
     UNNotificationActionOptionAuthenticationRequired = (1 << 0),

     黑色文字。点击不会进app。
     UNNotificationActionOptionDestructive = (1 << 1),

     黑色文字。点击会进app。
     UNNotificationActionOptionForeground = (1 << 2),
     */
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功 %@", requestIdentifier);
            //你自己的需求例如下面：
            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bingo" style:UIAlertActionStyleCancel handler:nil];
//                [alert addAction:cancelAction];
//                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
            

        }
    }];
}

- (NSSet *)catageryIdentifierWithIndex:(NSIndexPath *)index {
    switch (index.row) {
        case 2:
        {
            UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"input" title:@"评论一下" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive textInputButtonTitle:@"发送" textInputPlaceholder:@"tell me"];
            UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"textInPut" actions:@[text] intentIdentifiers:@[text.identifier] options:UNNotificationCategoryOptionCustomDismissAction];
            return [NSSet setWithObject:comment];
        }
            break;
        case 3:
        {
            UNNotificationAction * likeButton2 = [UNNotificationAction actionWithIdentifier:@"collection" title:@"收藏" options:UNNotificationActionOptionDestructive];
            UNNotificationAction * openButton = [UNNotificationAction actionWithIdentifier:@"openApp" title:@"大屏幕播放" options:UNNotificationActionOptionForeground];
            UNNotificationAction * dislikeButton2 = [UNNotificationAction actionWithIdentifier:@"open" title:@"播放" options:UNNotificationActionOptionDestructive];
            UNNotificationCategory * choseCategory3 = [UNNotificationCategory categoryWithIdentifier:@"video" actions:@[likeButton2,openButton,dislikeButton2] intentIdentifiers:@[likeButton2.identifier,openButton.identifier,dislikeButton2.identifier] options:UNNotificationCategoryOptionCustomDismissAction];
            return [NSSet setWithObject:choseCategory3];
        }
            break;
        case 4:
        {
            UNNotificationAction * score1 = [UNNotificationAction actionWithIdentifier:@"score1" title:@"满意程度？" options:UNNotificationActionOptionDestructive];
            UNNotificationAction * score2 = [UNNotificationAction actionWithIdentifier:@"score2" title:@"忽略" options:UNNotificationActionOptionNone];
            UNNotificationCategory * scoreCategory = [UNNotificationCategory categoryWithIdentifier:@"dynamicAction" actions:@[score1,score2] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionCustomDismissAction];
            return [NSSet setWithObject:scoreCategory];
        }
            break;

        default:
            break;
    }
    return nil;
}

// 指定时间进行通知
- (void)locoalCalendarNotification {
    NSDateComponents *components = [[NSDateComponents alloc]init];
    // 1 周日 2 周一……
    components.weekday = 6;
    components.hour = 10;
    components.minute = 57;
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"title: 日历提醒 ⏰";
    content.subtitle = @"subtitle: 提醒内容包括睡觉吃饭打豆豆";
    content.body = @"body: 时间到了，请选择待做事项，包括：吃饭、睡觉、打豆豆";
    content.badge = @66;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
    NSString *requestIdentifier = @"First";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功 %@", requestIdentifier);
            //你自己的需求例如下面：
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bingo" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
}

// 地理位置通知
- (void)locoalLocationNotification {
    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(39.8877900000,116.1133200000);//门头沟
//    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(39.9773100000,116.3057200000);// 苏州街
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:center1 radius:10000 identifier:@"苏州街"];
    region.notifyOnExit = YES;
    region.notifyOnEntry = YES;
    UNLocationNotificationTrigger *trigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"title: 位置提醒 ⏰";
    content.subtitle = @"subtitle: 提醒内容包括睡觉吃饭打豆豆";
    content.body = @"body: 时间到了，请选择待做事项，包括：吃饭、睡觉、打豆豆";
    content.badge = @66;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
    NSString *requestIdentifier = @"First";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"推送已添加成功 %@", requestIdentifier);
            //你自己的需求例如下面：
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Bingo" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            });
            

        }
    }];
    
}




@end
