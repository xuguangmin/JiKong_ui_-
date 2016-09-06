//
//  PHProgress.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-13.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;

@interface PHProgress : UIProgressView

@property (strong, nonatomic) NSString* controlId;
@property (assign, nonatomic) int orientation; //方向,0标示水平,1标示数值
@property (assign, nonatomic) int zIndex;
@property (assign, nonatomic) int nVisible;
@property (assign, nonatomic) int nEnable;
@property (assign, nonatomic) int nCurValue;

//@property (nonatomic, assign) double progress;


- (void)ParserXML:(GDataXMLElement*)elementy;

- (void)onValueChangedEvent;

//
//- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage *)backgroundImage foregroundImage:(UIImage *)foregroundImage;


@end
