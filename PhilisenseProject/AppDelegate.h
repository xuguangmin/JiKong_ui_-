//
//  AppDelegate.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@class RootViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    RootViewController *_rootViewController;
    UINavigationController * _NavCon;
    
    BOOL isConnet;                      //标记是否连接服务器成功

}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * NavCon;
@property (strong, nonatomic) RootViewController *rootViewController;

@property(nonatomic,retain) AsyncSocket *asyncSocket;

@end
