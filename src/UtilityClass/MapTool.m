//
//  MapTool.m
//  xss
//
//  Created by wzh on 2017/8/14.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "MapTool.h"
#define WEAKSELF     typeof(self) __weak weakSelf = self;
@implementation MapTool


+ (MapTool *)sharedMapTool{
    
    
    static MapTool *mapTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapTool = [[MapTool alloc] init];
    });
    
    return mapTool;
    
}

//根据经纬度换算出直线距离
+(float)getDistance:(float)lat1 lng1:(float)lng1 lat2:(float)lat2 lng2:(float)lng2{
    //地球半径
    int R = 6378137;
    //将角度转为弧度
    float radLat1 = (lat1*3.14159265)/180.0;
    float radLat2 = (lat2*3.14159265)/180.0;
    float radLng1 = (lng1*3.14159265)/180.0;
    float radLng2 = (lng2*3.14159265)/180.0;
    //结果
    float s = acos(cos(radLat1)*cos(radLat2)*cos(radLng1-radLng2)+sin(radLat1)*sin(radLat2))*R;
    //精度
    s = round(s* 10000)/10000;
    return  round(s);
}

static float DEF_PI=3.14159265359;
static float DEF_PI180=0.01745329252;
static float DEF_R=6370693.5;
+(NSMutableArray*)getRange:(float)lon lat:(float)lat:(float)r{
    NSMutableArray *range=[[NSMutableArray alloc] init];
    
    // 角度转换为弧度
    double ns = lat * DEF_PI180;
    
    double sinNs = sin(ns);
    double cosNs = cos(ns);
    double cosTmp = cos(r / DEF_R);
    // 经度的差值
    double lonDif = acos((cosTmp - sinNs * sinNs) / (cosNs * cosNs)) / DEF_PI180;
    // 保存经度
    [range insertObject:@(lon - lonDif) atIndex:0];
    [range insertObject:@(lon + lonDif) atIndex:1];
    //range[0] = lon - lonDif;
    //range[1] = lon + lonDif;
    double m = 0 - 2 * cosTmp * sinNs;
    double n = cosTmp * cosTmp - cosNs * cosNs;
    double o1 = (0 - m - sqrt(m * m - 4 * (n))) / 2;
    double o2 = (0 - m + sqrt(m * m - 4 * (n))) / 2;
    // 纬度
    double lat1 = 180 / DEF_PI * asin(o1);
    double lat2 = 180 / DEF_PI * asin(o2);
    // 保存
    [range insertObject:@(lat1) atIndex:2];
    [range insertObject:@(lat2) atIndex:3];
    //range[2] = lat1;
    //range[3] = lat2;
    return range;
}

@end
