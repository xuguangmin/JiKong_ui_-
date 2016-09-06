//
//  SocketServices.h
//  ZhongCaiRenMai
//
//  Created by huachang li on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CheckBox.h"
#import "RadioBox.h"
@class GDataXMLElement;
@class PageViewController;
@class PHButton;
@class PHSlider;

@interface ParserXMLService : NSObject<UIAlertViewDelegate,CheckBoxDelegate,RadioBoxDelegate>{
    
    NSString *_projectName; //工程名称
    
    NSString *_startPage;   //起始页
    
    NSString *_xmlFilePath; //xml资源文件路径
    
    NSString *rightpagename;
    
    NSString *leftpagename;
    
    NSMutableArray * _eventsArray;
}

@property (nonatomic) CGFloat screenWidth;  //屏幕宽度
@property (nonatomic) CGFloat screenHeight; //屏幕高度
@property (nonatomic) CGFloat pageWidth;    //页面宽度
@property (nonatomic) CGFloat pageHeight;   //页面高度

@property (nonatomic) CGFloat hRatio;       //横向比
@property (nonatomic) CGFloat cRatio;       //纵向比

@property (strong,nonatomic) PageViewController *newviewcontroller;
@property (strong,nonatomic) NSString *projectName;
@property (strong,nonatomic) NSString *currentpagename;
@property (strong,nonatomic) NSString *startPage;
@property (strong,nonatomic) NSString *xmlFilePath;
@property (strong,nonatomic) PHButton *button1;
@property (strong,nonatomic) NSMutableArray *eventsArray;
@property (assign,nonatomic) int pageidcount;
@property (assign,nonatomic) int Id;

+(ParserXMLService *)sharedParserXMLService;
+(UIColor *) colorWithHexString: (NSString *)color;

-(void)parserXml;
-(void)parserXmlWithName:(NSString*)name;
-(void)parserXmlWithDocument:(GDataXMLElement *)ele;

-(void)dealwithPendingEvents:(PageViewController*)controller;   //待处理事件
-(void)dealwithEventsInPresentedView:(NSString*)event;          //处理当前页面事件
-(BOOL)dealwithEventsinView:(PageViewController*)controller withEvent:(NSString*)event;//处理指定控制器内事件

@end
