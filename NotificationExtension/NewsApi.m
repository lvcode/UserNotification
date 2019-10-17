

//
//  NewsApi.m
//  NotificationExtension
//
//  Created by Lv Qiang on 2019/10/10.
//  Copyright © 2019 Lv Qiang. All rights reserved.
//

#import "NewsApi.h"

@implementation NewsApi

- (NSString *)requestUrl {
    // “http://www.yuantiku.com” is set in YTKNetworkConfig, so we ignore it
    return @"/journalismApi";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

@end
