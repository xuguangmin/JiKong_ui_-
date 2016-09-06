//
//  SGMSettingConfig.h
//  Speech SDK
//
//  Created by rosschen on 12-12-28.
//  Copyright (c) 2012年 rosschen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGMSettingConfig : NSObject{
    
}
@property(nonatomic,strong) NSString *macstring;
//获取设备MAC地址
-(NSString *)macAddress;

//给定信息进行MD5
-(NSString *)getMD5:(NSString *)paramStr;

//给设备MAC地址进行MD5加密
-(NSString *)macMD5;

@end
