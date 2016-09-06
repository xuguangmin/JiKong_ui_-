//
//  PageViewControllerViewController.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"
#import "ParserXmlService.h"
#import "global.h"
#import "UserBasicInfo.h"
#import "LoginViewController.h"
#import "UserBasicInfo.h"
#import "Utilities.h"
#import "Reachability.h"
#import "PHAlertView.h"
#import "SocketServices.h"
#import "PHSlider.h"
@interface PageViewController ()

@end

@implementation PageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    UISwipeGestureRecognizer *swipegestureleft = [[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeGestureLeft:)]autorelease];
    
    UISwipeGestureRecognizer *swipegestureright = [[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(SwipeGestureRight:)]autorelease];
    
    
    swipegestureleft.direction = UISwipeGestureRecognizerDirectionLeft;
    swipegestureright.direction = UISwipeGestureRecognizerDirectionRight;
    
    swipegestureright.delegate=self;
    swipegestureleft.delegate=self;
    
    UILongPressGestureRecognizer *longlongGesture=[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
    //设置长按时间间隔
    longlongGesture.delegate=self;
    longlongGesture.minimumPressDuration = 1.0;
    
    
    
    [self.view addGestureRecognizer:longlongGesture];
    [self.view addGestureRecognizer:swipegestureleft];
    [self.view addGestureRecognizer:swipegestureright];
}

//解决让按钮不响应长按接收手势事件
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]])
        
    {
        return NO;
    }
    if ([touch.view isKindOfClass:[PHSlider class]])
        
    {
        return NO;
    }
    
    return YES;
}
-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    
    switch (sender.state)
    {
        case UIGestureRecognizerStateEnded:
            
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateBegan:
            NSLog(@"______________长按事件————————");
            
            
            PHAlertView *loginPrompt = [[PHAlertView alloc] initWithTitle:@"重新连接" delegate:self cancelButtonTitle:@"取消" otherButtonTitle:@"登录"];
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString* serverIP = [userDefaults objectForKey:KEY_SERVER_IP];//读取服务器ip键的值
            NSString* serverPort = [userDefaults objectForKey:KEY_SERVER_PORT];//读取服务器port键的值
            
            loginPrompt.plainTextField.text=serverIP;
            loginPrompt.secretTextField.text=serverPort;
            [loginPrompt show];
            
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        default:
            break;
    }
    
    
    
}


#pragma mark AlertViewDelegate

- (void)didPresentAlertView:(UIAlertView *)alertView {
	if ([alertView isKindOfClass:[PHAlertView class]]) {
        
		PHAlertView *loginPrompt = (PHAlertView *)alertView;
		[loginPrompt.plainTextField becomeFirstResponder];
		[loginPrompt setNeedsLayout];
	}
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == [alertView cancelButtonIndex]) {
        
	} else {
        
		if ([alertView isKindOfClass:[PHAlertView class]]) {
            
			PHAlertView *loginPrompt = (PHAlertView *)alertView;
            
            //存入UserDefaults
            NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
            [accountDefaults setObject:loginPrompt.plainTextField.text forKey:KEY_SERVER_IP];
            [accountDefaults setObject:loginPrompt.secretTextField.text forKey:KEY_SERVER_PORT];
            [accountDefaults synchronize];
            //连接服务器
            [[SocketServices sharedSocketServices]login:loginPrompt.plainTextField.text withServerPort:loginPrompt.secretTextField.text];
		}
	}
}

-(void)SwipeGestureLeft:(UISwipeGestureRecognizer *)sender
{
    
    if (![self.leftPageName isEqualToString:@""])
    {
        ParserXMLService *parserXMLServer = [ParserXMLService sharedParserXMLService];
        if(parserXMLServer)
        {
            [parserXMLServer parserXmlWithName:self.leftPageName];
        }
    }
}

-(void)reponseLoginNotifiction{
    
    UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
    if ([userInfo.logInStatus isEqualToString:@"0"]) {
        //网络连接断开，返回登录页面从新登录
        LoginViewController * loginViewController = [LoginViewController sharedloginViewController];
        if (loginViewController) {
            //            [self presentModalViewController:loginViewController animated:YES];
            [self presentViewController:loginViewController animated:YES completion:^{
                
            }];
        }
    }
}

/*
 -(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
 {
 if(buttonIndex == 1){   //继续尝试连接
 LoginViewController * loginViewController = [LoginViewController sharedloginViewController];
 if(loginViewController)
 {
 [loginViewController.loginButton setEnabled:YES];
 [loginViewController.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
 }
 }else if(buttonIndex == 2){ //运行单机版
 UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
 if(userInfo){
 userInfo.runModel = @"0";   //标示为单机运行模式
 }
 ParserXMLService *parserXMLServer = [ParserXMLService sharedParserXMLService];
 if(parserXMLServer)
 {
 [parserXMLServer  parserXml];
 }
 }
 
 }
 */
-(void)SwipeGestureRight:(UISwipeGestureRecognizer *)sender
{
    
    if (![self.rightPageName isEqualToString:@""]) {
        ParserXMLService *parserXMLServer = [ParserXMLService sharedParserXMLService];
        if(parserXMLServer)
        {
            [parserXMLServer parserXmlWithName:self.rightPageName];
        }
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft|interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
