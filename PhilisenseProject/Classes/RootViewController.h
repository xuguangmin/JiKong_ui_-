//
//  RootViewController.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-8.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SGMSettingConfig;
@class UserBasicInfo;
@interface RootViewController : UIViewController{
    UIImageView *_backgroundimageView1;
    UIImageView *_backgroundimageView;
    UIView *_backgroundView;
    UITextField *inputField0;
    UITextField *inputField1;
    UITextField *inputField2;
    UITextField *inputField3;
    NSString *macadressmd50;
    NSString *macadressmd51;
    NSString *macadressmd52;
    NSString *macadressmd53;
    UserBasicInfo * userInfo;
    SGMSettingConfig *sgmSettingConfig;
}
@property (nonatomic ,strong)NSString *macadressmd50;
@property (nonatomic ,strong)NSString *macadressmd51;
@property (nonatomic ,strong)NSString *macadressmd52;
@property (nonatomic ,strong)NSString *macadressmd53;
@end
