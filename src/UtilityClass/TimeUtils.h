//
//  TimeUtils.h
//  lineliao
//
//  Created by zhanshengshu on 18/3/14.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtils : NSObject
+ (NSString *)getSystemTime:(NSString *)format; // 获取系统当前时间
+(NSString *)getYestodayTime:(NSString *)format; // 获取昨天时间
+ (NSDate *)getTime:(NSString *)format time:(NSString *)time; // 获取时间
+ (NSString *)changeTimeStr:(NSString *)chageFormat format:(NSString *)format time:(NSString *)time; // 转换时间
@end
