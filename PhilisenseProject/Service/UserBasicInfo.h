//
//  UserBasicInfo.h
//  ZhongCaiRenMai
//
//  Created by 伟 李 on 12-8-23.
//  Copyright (c) 2012年 搜房网. All rights reserved.
//

#import <Foundation/Foundation.h>
#define KEY_USERID (@"USERID") 


@interface UserBasicInfo : NSObject

@property (nonatomic,strong) NSString * logInStatus;//登录状态(1:标示已登录,0:标示未登录)
@property (nonatomic,strong) NSString * userID;  
@property (nonatomic,strong) NSString * serverIP;
@property (nonatomic,strong) NSString * serverPort;
@property (nonatomic,strong) NSString * validateStatus;//验证状态(1:标示已验证,0:标示未验证)
@property (nonatomic,strong) NSString * runModel;   //运行模式,单机版或者连机版,默认为连机模式(1:标示连机,0:标示单机模式)

+(UserBasicInfo *)sharedUserBasicInfo;

@end
