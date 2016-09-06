//
//  RootViewController.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "UserBasicInfo.h"
#import "LoginViewController.h"
#import "SGMSettingConfig.h"
#import "global.h"
#import "SocketServices.h"

@interface RootViewController ()

@end
@implementation RootViewController
@synthesize macadressmd50,macadressmd51,macadressmd52,macadressmd53;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

//横向显示
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft|interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft|toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];

    userInfo=[UserBasicInfo sharedUserBasicInfo];
    //木有md5加密页
    if (userInfo) {
        if (![userInfo.logInStatus isEqualToString:@"1"]) {
            //没有登录,首先要登录
            LoginViewController * loginViewController =[LoginViewController sharedloginViewController];
            if (loginViewController) {
                if (![self.presentedViewController isBeingDismissed])
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self presentViewController:loginViewController animated:NO completion:^{
                        
                    }];
                }
            
            }

        }
        
        //登录过后自动连接
        [[SocketServices sharedSocketServices]login:userInfo.serverIP withServerPort:userInfo.serverPort];
        
        //(1:标示已登录,0:标示未登录)

    }
//    //有md5加密的页面
//    if(userInfo){
//        if([userInfo.runModel isEqualToString:@"1"]){
//            if (![userInfo.validateStatus isEqualToString:@"1"]) {
//                //没有验证，首先要验证
//                //添加验证页面
//                UIView *validateView=[[[UIView alloc]initWithFrame:CGRectMake(0, 0, 1024, 768)]autorelease];
//                validateView.backgroundColor=[UIColor scrollViewTexturedBackgroundColor];
//                [self.view addSubview:validateView];
//                
//                sgmSettingConfig=[[SGMSettingConfig alloc]init];
//                NSString *macadress= [sgmSettingConfig macAddress];
//                //注册码凭证的生成为mac地址md5加密一次获取前8位
//                NSString *validatecode=[[sgmSettingConfig getMD5:macadress]substringToIndex:10];
//                //注册码验证为注册码凭证md5加密两次
//                NSString *macadressmd5=[sgmSettingConfig getMD5:[sgmSettingConfig getMD5:validatecode]];
//                self.macadressmd50=[macadressmd5 substringToIndex:5];
//                self.macadressmd51=[[macadressmd5 substringFromIndex:8]substringToIndex:5];
//                self.macadressmd52=[[macadressmd5 substringFromIndex:16]substringToIndex:5];
//                self.macadressmd53=[[macadressmd5 substringFromIndex:24]substringToIndex:5];
//                NSString *enrol=[NSString stringWithFormat:@"%@---%@---%@---%@",self.macadressmd50,self.macadressmd51,self.macadressmd52,self.macadressmd53];
//                NSLog(@"enrol===================================\n%@",enrol);
//        
//                inputField0 = [[UITextField alloc] initWithFrame:CGRectMake(100, 212, 131, 30)];
//                inputField0.borderStyle = UITextBorderStyleRoundedRect;
//                inputField0.textAlignment=NSTextAlignmentCenter;
//                [validateView addSubview:inputField0];
//                
//                inputField1 = [[UITextField alloc] initWithFrame:CGRectMake(331, 212, 131, 30)];
//                inputField1.borderStyle = UITextBorderStyleRoundedRect;
//                inputField1.textAlignment=NSTextAlignmentCenter;
//                [validateView addSubview:inputField1];
//                
//                inputField2 = [[UITextField alloc] initWithFrame:CGRectMake(562, 212, 131, 30)];
//                inputField2.borderStyle = UITextBorderStyleRoundedRect;
//                inputField2.textAlignment=NSTextAlignmentCenter;
//                [validateView addSubview:inputField2];
//                
//                inputField3 = [[UITextField alloc] initWithFrame:CGRectMake(793, 212, 131, 30)];
//                inputField3.borderStyle = UITextBorderStyleRoundedRect;
//                inputField3.textAlignment=NSTextAlignmentCenter;
//                [validateView addSubview:inputField3];
//                
//                UILabel *outputLabel = [[[UILabel alloc] initWithFrame:CGRectMake(352, 112, 320, 50)]autorelease];
//                outputLabel.numberOfLines=0;
//                outputLabel.textColor=[UIColor whiteColor];
//                outputLabel.textAlignment = NSTextAlignmentCenter;
//                outputLabel.text=[NSString stringWithFormat:@"获取注册码凭证:%@",validatecode];
//                outputLabel.backgroundColor=[UIColor clearColor];
//                [validateView addSubview:outputLabel];
//                UIButton *validateBut=[UIButton buttonWithType:UIButtonTypeRoundedRect];
//                validateBut.frame=CGRectMake(462, 302, 100, 50);
//                [validateBut addTarget:self action:@selector(validate:) forControlEvents:UIControlEventTouchUpInside];
//                [validateBut setTitle:@"注册" forState:UIControlStateNormal];
//                [validateView addSubview:validateBut];
////                [validateBut release];
//                
//            }else{
//                if (![userInfo.logInStatus isEqualToString:@"1"]) {
//                    //没有登录,首先要登录
//                    LoginViewController * loginViewController =[LoginViewController sharedloginViewController];
//                    [self.parentViewController presentModalViewController:loginViewController animated:NO];
//                }
//            }
//        }
//    }
}

-(void)validate:(id)sender{
        if (userInfo.validateStatus==nil) {
        if ([inputField0.text isEqualToString:self.macadressmd50]&&[inputField1.text isEqualToString:self.macadressmd51]&&[inputField2.text isEqualToString:self.macadressmd52]&&[inputField3.text isEqualToString:self.macadressmd53])
        {
            UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message:@"注册成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            userInfo.validateStatus=@"1";
            NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
            [accountDefaults setObject:userInfo.validateStatus forKey:KEY_VALIDATESTATUS];
            [accountDefaults synchronize];
            
            if (![userInfo.logInStatus isEqualToString:@"1"]) {
                //没有登录,首先要登录
                LoginViewController * loginViewController =[LoginViewController sharedloginViewController];
                [self.parentViewController presentViewController:loginViewController animated:NO completion:^{
                }];
            }

            //  [[SocketServices sharedSocketServices]login:@"192.168.1.220" withServerPort:@"9000"];
        }
    }
    

}

@end
