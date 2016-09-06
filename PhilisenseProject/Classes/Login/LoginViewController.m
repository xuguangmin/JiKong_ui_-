//
//  LoginViewController.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "Utilities.h"
#import "AppDelegate.h"
#import "UserBasicInfo.h"
#import "SocketServices.h"
#import "global.h"
#import "ParserXmlService.h"
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
static LoginViewController *_sharedloginViewController;

@implementation LoginViewController
@synthesize serverIPTextField=_userNameTextField,serverPortTextField=_passWordTextField, loginButton=_loginButton,backgroundImageView;

-(void)viewDidLoad{
    
    [self registerForKeyboardNotifications];
    
    UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
    //设置登录窗口背景图片
    [self.view setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    self.backgroundImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)]autorelease];
    self.backgroundImageView.userInteractionEnabled =YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(Tap)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];

    backgroundImageView.image = [UIImage imageNamed:@"登录页.png"];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UITextField * ipTextField = [[UITextField alloc]initWithFrame:CGRectMake(435, 364, 240, 30)];
    [ipTextField setFont:[UIFont systemFontOfSize:22]];
    NSString* serverIP = [userDefaults objectForKey:KEY_SERVER_IP];//读取服务器ip键的值
    if(!serverIP)
        ipTextField.placeholder=@"请输入服务器IP地址";
    else {
        ipTextField.placeholder= serverIP;  [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                     selector:@selector(reponseLoginNotifiction:)
                                                                                         name:REQEST_NOTIFICATION_TYPE_LOGIN object:nil];
    }
    
    ipTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;// 垂直对齐方式 
    ipTextField.keyboardType = UIKeyboardTypeDefault;//UIKeyboardTypeDefault;//键盘的种类
    ipTextField.autocorrectionType = UITextAutocorrectionTypeNo;//纠错
    ipTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    ipTextField.returnKeyType = UIReturnKeyNext;//键盘中的Done键
    ipTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    ipTextField.delegate = self;
    
    
    ipTextField.text = @"119.40.53.172";
    if (![UtilityHelper isEmpty:userInfo.serverIP]) {
      ipTextField.text = userInfo.serverIP;
    }

    [self.backgroundImageView addSubview:ipTextField];
    self.serverIPTextField = ipTextField;
    [ipTextField release];

    
    UITextField * portTextField = [[UITextField alloc]initWithFrame:CGRectMake(435, 414, 240, 30)];
    [portTextField setFont:[UIFont systemFontOfSize:22]];
    NSString* serverPort = [userDefaults objectForKey:KEY_SERVER_IP];//读取服务器port键的值
    if(!serverPort)
        portTextField.placeholder = @"请输入端口号";
    else {
        portTextField.placeholder = serverPort;
    }

    portTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;    
    portTextField.keyboardType = UIKeyboardTypeNumberPad;//键盘的种类
    portTextField.autocorrectionType = UITextAutocorrectionTypeNo;//纠错
    portTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    portTextField.returnKeyType = UIReturnKeyDone;//键盘中的Done键
    portTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    portTextField.delegate = self;
    
    
    portTextField.text = @"9001";
    if (![UtilityHelper isEmpty:userInfo.serverPort]) {
        
        portTextField.text = userInfo.serverPort;
    }

    [self.backgroundImageView addSubview:portTextField];
    self.serverPortTextField = portTextField;
    [portTextField release];

    UIButton * quitButton =[[UIButton alloc]initWithFrame:CGRectMake(480, 488, 89, 50)];
    [quitButton setBackgroundImage:[UIImage imageNamed:@"登录.png"] forState:UIControlStateNormal];
    [quitButton setTitle:@"退 出" forState:UIControlStateNormal];
    [quitButton addTarget:self action:@selector(quit) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundImageView addSubview:quitButton];
    [quitButton release];
    
    UIButton * loginButton =[[UIButton alloc]initWithFrame:CGRectMake(582, 488, 89, 50)];
    [loginButton setBackgroundImage:[UIImage imageNamed:@"登录.png"] forState:UIControlStateNormal];
    [loginButton setTitle:@"登 录" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundImageView addSubview:loginButton];
    self.loginButton = loginButton;
    [loginButton release];
    

    _backgroundimageView1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)];
    _backgroundimageView1.image=[UIImage imageNamed:@"背景图.png"];
    
    
    [self.view addSubview:_backgroundimageView1];
    
    [self performSelector:@selector(TheAnimation) withObject:nil afterDelay:3];

}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reponseLoginNotifiction:)
                                                 name:REQEST_NOTIFICATION_TYPE_LOGIN object:nil];
    cannet = NO;
}



-(void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWasShown:(NSNotification*)aNotification
{[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.backgroundImageView.frame=CGRectMake(0, -140, 1024, 768);
    [UIView commitAnimations];
}
-(void)keyboardWasHidden:(NSNotification*)aNotification
{

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    self.backgroundImageView.frame=CGRectMake(0, 0, 1024, 768);
    [UIView commitAnimations];
}

-(void) Tap
{
    [self.serverIPTextField resignFirstResponder];
    [self.serverPortTextField resignFirstResponder];
}

-(void)viewDidUnload
{
    
    self.loginButton = nil;
    self.serverIPTextField = nil;
    self.serverPortTextField = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:REQEST_NOTIFICATION_TYPE_LOGIN object:nil];
    [super viewDidUnload];
}

-(void)alertBlankMessage: (NSString *) message{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message
                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles: @"确定" ,nil];
    alert.tag=0;
    [alert show];
    [alert release];
}

-(void)login
{
    if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable ||[[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
    {
        cannet = YES;
    }else{
        cannet = NO;
    }
    
    if (cannet)
    {
        [self.loginButton setEnabled:NO];
        NSString * userName = self.serverIPTextField.text ;
        NSString * passWord = self.serverPortTextField.text;
        
        if (userName.length == 0) {
            [self alertBlankMessage:@"IP不能为空"];
            return;
        }
        
        if (passWord.length == 0) {
            [self alertBlankMessage:@"端口不能为空"];
            return;
        }
        
        
        if (![UtilityHelper isEmpty:userName]&&![UtilityHelper isEmpty:passWord])
        {
            UIActivityIndicatorView *myactivityindicatorview = [[[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(520, 512, 20, 20)]autorelease];
            [myactivityindicatorview setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            self.myactivityIndicatorView = myactivityindicatorview;
            [self.myactivityIndicatorView startAnimating];
            [self.backgroundImageView addSubview:self.myactivityIndicatorView];
            
            [[SocketServices sharedSocketServices]login:self.serverIPTextField.text withServerPort:self.serverPortTextField.text];
        }
    }
    else
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"无连接" message:@"无线网络无连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        [alertview release];
    }
}

//退出应用程序
-(void)quit
{
    [[UserBasicInfo sharedUserBasicInfo] release];//
    [[[SocketServices sharedSocketServices] asyncSocket] disconnect];
    [[SocketServices sharedSocketServices] release];
    [[ParserXMLService sharedParserXMLService] release];
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        window.alpha = 0;
        self.view.frame = CGRectMake(window.bounds.size.width/2,window.bounds.size.height/2,0,0);
     } completion:^(BOOL finished) {
         exit(1);
     }];
}

-(void)reponseLoginNotifiction:(id)sender{
    
    UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
    if ([userInfo.logInStatus isEqualToString:@"1"]) {
        NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
        [accountDefaults setObject:self.serverIPTextField.text forKey:KEY_SERVER_IP];
        [accountDefaults setObject:self.serverPortTextField.text forKey:KEY_SERVER_PORT];
        [accountDefaults synchronize];
    }
    else
    {
        if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable ||[[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable)
        {
            cannet = YES;
        }else{
            cannet = NO;
        }
        [self.loginButton setEnabled:YES];
        [self.myactivityIndicatorView removeFromSuperview];
        if (cannet) {
            //提示用户继续操作
//            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"网络连接失败" message:@"重新尝试连接,还是运行单机版程序?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续尝试",@"运行单机版", nil];
//            [alertView show];
//            [alertView release];
        }else{
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"无连接" message:@"无线网络无连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertview show];
            [alertview release];
        }
    }

}

// return NO to disallow editing.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.serverIPTextField]) {
        [self.serverPortTextField becomeFirstResponder];
    }else{
        [self login];
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex == 1){   //继续尝试连接
        [self.loginButton setEnabled:YES];
        [self.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else if(buttonIndex == 2){ //运行单机版
        UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
        if(userInfo){
            userInfo.runModel = @"0";  //标示为单机运行模式
        }
        [[ParserXMLService sharedParserXMLService] parserXml];
    }
}

-(void)TheAnimation{
    
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.7;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    animation.type = kCATransitionFade;
    NSUInteger f = [[self.view subviews]indexOfObject:_backgroundimageView1];
    NSUInteger s = [[self.view subviews]indexOfObject:self.backgroundImageView];
    [[self.view layer] addAnimation:animation forKey:@"animation"];
    [self.view exchangeSubviewAtIndex:s withSubviewAtIndex:f];
    [self performSelector:@selector(diss) withObject:nil afterDelay:1];
}
-(void)diss{
    [_backgroundimageView1 removeFromSuperview];
}
-(void)ToUpSide{
    [UIView animateWithDuration:0.7 animations:^{
        _backgroundimageView1.frame=CGRectMake(1024,
                                         0,
                                         self.view.frame.size.width,
                                         self.view.frame.size.height);
    }
                     completion:^(BOOL finished) {
                     }];
}

//横屏显示
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft|interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

+(LoginViewController *)sharedloginViewController{
    
    @synchronized([LoginViewController class]){
        if (!_sharedloginViewController) {
            _sharedloginViewController=[[[LoginViewController alloc]init]autorelease];
        }
        return _sharedloginViewController;
        
    }
    return nil;
}

-(void)dealloc{
    [_loginButton release];
    [_userNameTextField release];
    [_passWordTextField release];
    [super dealloc];
}
@end
