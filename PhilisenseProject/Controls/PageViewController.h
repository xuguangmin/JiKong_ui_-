//
//  PageViewControllerViewController.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageViewController : UIViewController<UIGestureRecognizerDelegate,UIActionSheetDelegate,UITextFieldDelegate>

@property (strong, nonatomic) NSString* currentPageName;
@property (strong, nonatomic) NSString* rightPageName;
@property (strong, nonatomic) NSString* leftPageName;
@property (strong, nonatomic) NSMutableArray* buttonPopupPageArray;
@property (strong, nonatomic) NSMutableArray* controlType;
@property (assign, nonatomic) int pageCount;
@property (assign, nonatomic) int pageId;

//@property(nonatomic,retain) UIButton * loginButton;
@property(nonatomic,retain) UIImageView *backgroundImageView;

@property(nonatomic,retain) UITextField * serverIPTextField;
@property(nonatomic,retain) UITextField * serverPortTextField;
@end
