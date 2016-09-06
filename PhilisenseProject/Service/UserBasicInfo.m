//
//  UserBasicInfo.m
//  ZhongCaiRenMai
//
//  Created by 伟 李 on 12-8-23.
//  Copyright (c) 2012年 搜房网. All rights reserved.
//

#import "UserBasicInfo.h"
#import "global.h"

static UserBasicInfo * _sharedUserBasicInfo = nil;

@implementation UserBasicInfo
@synthesize userID;  
@synthesize serverIP,serverPort,logInStatus,validateStatus;
@synthesize runModel;

- (id)init
{
    self = [super init];
    if (self) {
        self.serverIP = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SERVER_IP];
        self.serverPort = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_SERVER_PORT];
        self.validateStatus =[[NSUserDefaults standardUserDefaults] objectForKey:KEY_VALIDATESTATUS];
        self.logInStatus = @"0";
        self.runModel = @"1";
        
     }
    
    return self;
}
+(UserBasicInfo *)sharedUserBasicInfo
{
    @synchronized([UserBasicInfo class])  
    {  
        if (!_sharedUserBasicInfo){  
            _sharedUserBasicInfo = [[UserBasicInfo alloc] init];
        }
        
        return _sharedUserBasicInfo;  
    }  
    
    return nil;
}

- (void)dealloc
{
    [logInStatus release];
    [userID release];
    [serverIP release];
    [serverPort release];
    [super dealloc];
}


@end
