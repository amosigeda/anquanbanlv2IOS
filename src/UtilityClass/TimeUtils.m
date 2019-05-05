//
//  TimeUtils.m
//  lineliao
//
//  Created by zhanshengshu on 18/3/14.
//  Copyright © 2018年 ZJ. All rights reserved.
//

#import "TimeUtils.h"

@implementation TimeUtils

/**
 * 获取系统当前时间
 */
+(NSString *)getSystemTime:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(format){
        [formatter setDateFormat:format];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    return timeStr;
}

/**
 * 获取昨天时间
 */
+(NSString *)getYestodayTime:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(format){
        [formatter setDateFormat:format];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString *timeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24]];
    return timeStr;
}

+(NSDate *)getTime:(NSString *)format time:(NSString *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(format){
        [formatter setDateFormat:format];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSDate *date = [formatter dateFromString:time];
    return date;
}

+ (NSString *)changeTimeStr:(NSString *)chageFormat format:(NSString *)format time:(NSString *)time{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(chageFormat){
        [formatter setDateFormat:chageFormat];
    }else{
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    NSString *timeStr = [formatter stringFromDate:[self getTime:format time:time]];
    return timeStr;
}

@end
