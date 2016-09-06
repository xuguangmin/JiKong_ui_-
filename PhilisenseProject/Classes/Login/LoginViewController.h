//
//  LoginViewController.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface LoginViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    UIImageView *_backgroundimageView1;
    UIImageView *_backgroundimageView;
    UIView *_backgroundView;
    BOOL cannet;
}

@property(nonatomic,retain) UITextField * serverIPTextField;
@property(nonatomic,retain) UITextField * serverPortTextField;
@property(nonatomic,retain) UIButton * loginButton;
@property(nonatomic,retain) UIImageView *backgroundImageView;
@property(nonatomic,retain) UIActivityIndicatorView *myactivityIndicatorView;

+(LoginViewController *)sharedloginViewController;
-(void)login;
@end
