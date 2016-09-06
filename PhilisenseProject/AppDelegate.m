//
//  AppDelegate.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "SocketServices.h"
#import "RootViewController.h"
#import "global.h"
#import "UserBasicInfo.h"
@implementation AppDelegate

@synthesize window = _window;
@synthesize NavCon = _NavCon;
@synthesize rootViewController = _rootViewController;

- (void)dealloc
{
    [_window release];
    [_NavCon release];
    [_rootViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [SocketServices sharedSocketServices];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    RootViewController *rootViewController =[[[RootViewController alloc]init]autorelease];
    self.NavCon = [[[UINavigationController alloc] initWithRootViewController:rootViewController]autorelease];
    self.window.rootViewController = _NavCon;
//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"进入后台状态");


}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        NSLog(@"进入前台了————————");
        NSLog(@"=======");
    

    [[NSNotificationCenter defaultCenter] postNotificationName:REQEST_NOTIFICATION_TYPE_LOGIN object:self];
    
     [self performSelector:@selector(sendReLogin) withObject:nil afterDelay:1];
    //[self performSelector:@selector(sendEnterLogin) withObject:nil afterDelay:1];
}

- (void)sendReLogin{
    
    UserBasicInfo *userinfo=[UserBasicInfo sharedUserBasicInfo];
    
    [[SocketServices sharedSocketServices]login:userinfo.serverIP withServerPort:userinfo.serverPort];
    
    NSLog(@"userinfo.serverIP__%@",userinfo.serverIP);
    NSLog(@"重新连接——————————");

}

-(void)sendEnterLogin{
    
    Byte buff[] = {0x01};//表示ios界面资源文件(压缩包)
    //客户端请求连接
    SocketServices *sockservice=[SocketServices sharedSocketServices];
    [sockservice sendPacketWith:0x10 WithCommand:0x02 WithData:nil dataLength:0];
    //请求文件版本信息
    [sockservice sendPacketWith:0x12 WithCommand:0x04 WithData:buff dataLength:1];
    
    AsyncSocket *sock=[[AsyncSocket alloc] initWithDelegate:self];

    [sockservice onSocket:sock didConnectToHost:@"192.168.1.220" port:9000];
    
    self.asyncSocket=sock;
    
    NSError *error=nil;
    if(![sock connectToHost:@"192.168.1.220" onPort:9000 withTimeout:30.00  error:&error])
    {
        NSLog(@"Error: %@", error);
    }
    [sock readDataWithTimeout:-1 tag:1];
    NSLog(@"重新连接——————————");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
