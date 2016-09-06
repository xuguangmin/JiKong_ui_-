//
//  SocketServices.m
//  ZhongCaiRenMai
//
//  Created by huachang li on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <stdio.h>
#import <string.h>
#import "ParserXmlService.h"
#import "AppDelegate.h"
#import "SocketServices.h"
#import "RootViewController.h"
#import "UserBasicInfo.h"
#import "global.h"
#import "GDataXMLNode.h"
#import <QuartzCore/QuartzCore.h>
#import "PageViewController.h"
#import "PHButton.h"
#import "PHSlider.h"
#import "PHLabel.h"
#import "CheckBox.h"
#import "PHProgress.h"
#import "RadioBox.h"

static ParserXMLService * _sharedParserXMLService = nil;

@implementation ParserXMLService

@synthesize screenWidth;
@synthesize screenHeight;
@synthesize pageWidth;
@synthesize pageHeight;
@synthesize projectName = _projectName;
@synthesize startPage = _startPage;
@synthesize xmlFilePath = _xmlFilePath;
@synthesize cRatio;
@synthesize hRatio;
@synthesize eventsArray = _eventsArray;
@synthesize newviewcontroller;
@synthesize button1;
@synthesize pageidcount;
@synthesize Id;
@synthesize currentpagename;
-(id)init{
    self=[super init];
    if (self)
    {
        CGRect rect = [[UIScreen mainScreen] bounds];
        CGSize size = rect.size;
        self.screenWidth = size.width;
        self.screenHeight = size.height;
        
        if(self.screenWidth < self.screenHeight)
        {
            self.screenWidth = size.height;
            self.screenHeight = size.width;
        }
        
        self.projectName = nil;
        self.xmlFilePath = nil;
        self.startPage = nil;
        self.button1 =[[[PHButton alloc]init]autorelease];
        
        self.eventsArray = [NSMutableArray array];
    }
    return self;
}

+(ParserXMLService *)sharedParserXMLService
{
    @synchronized([ParserXMLService class])
    {
        if (!_sharedParserXMLService)
            _sharedParserXMLService = [[ParserXMLService alloc] init];
        
        return _sharedParserXMLService;
    }
    
    return nil;
}
//转化颜色
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f)
                            blue:((float) b / 255.0f) alpha:1.0f];
}
//解析工程信息
-(void)parserXml
{
    
    NSString *strErr = nil;
    Id =2;
    SocketServices *socketService = [SocketServices sharedSocketServices];
    if(socketService)
    {
        NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* zipFileName = [userDefaults objectForKey:KEY_ZIP_FILENAME];
        if(zipFileName)
        {
            //获取xml文件名称
            NSRange  range = [zipFileName rangeOfString:ZIP_SUFFIX];
            NSString *xmlFileName = [zipFileName stringByReplacingCharactersInRange:range
                                                                         withString:XML_SUFFIX];
            //获取xml文件全路径
            self.xmlFilePath = [socketService.xmlSourcePath stringByAppendingPathComponent:xmlFileName];
            
            NSData* dataXML = [NSData dataWithContentsOfFile:self.xmlFilePath];
            if(dataXML)
            {
                //对NSData对象初始化
                NSError* error=nil;
                GDataXMLDocument* gdataXMLDoc = [[[GDataXMLDocument alloc]
                                                  initWithData:dataXML options:0  error:&error] autorelease];
                
                GDataXMLElement * rootElement = [gdataXMLDoc rootElement];
                /*HMUIS的属性*/
                self.pageWidth = [[[rootElement attributeForName:XML_WIDTH_ATTR] stringValue] floatValue];
                self.pageHeight = [[[rootElement attributeForName:XML_HEIGHT_ATTR] stringValue] floatValue];
                //                NSLog(@"self.screenwidth=========%f",self.screenWidth);
                //                 NSLog(@"self.screenHeight=========%f",self.screenHeight);
                
                self.hRatio = (CGFloat)self.screenWidth/self.pageWidth;     //横向比
                self.cRatio = (CGFloat)self.screenHeight/self.pageHeight;   //纵向比
                
                self.startPage = [[rootElement attributeForName:XML_STARTPAGE_ATTR] stringValue];
                self.projectName = [[rootElement attributeForName:XML_NAME_ATTR] stringValue];
                
                if (self.startPage)
                {
                    
                    [self parserXmlWithName:self.startPage];
                    return;
                }
                
            }
            
        }
        
        strErr = @"压缩资源文件不存在/资源文件错误/资源文件为空/加载资源文件失败";
    }
    
    //应用程序退出
    UIAlertView * alertView =[[UIAlertView alloc]initWithTitle:@"错误" message:strErr
                                                      delegate:nil cancelButtonTitle:@"退出" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    //退出应用程序
    //    [[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
}
//解析指定的页面
-(void)parserXmlWithDocument:(GDataXMLElement *)ele
{
    if(ele)
    {
        SocketServices *socketServer = [SocketServices sharedSocketServices];
        if(socketServer){
            
            NSString *imageSourcePath = [socketServer.xmlSourcePath
                                         stringByAppendingPathComponent:IMAGE_RESOURCE];
            NSString *backgroundImage = [[ele attributeForName:XML_BACKGROUNDIMAGE_ATTR]
                                         stringValue];
            NSString *backgroundColor = [[ele attributeForName:XML_BACKGROUNDCOLOR_ATTR]
                                         stringValue];
            
            PageViewController* newView = [[PageViewController alloc] init];
            self.newviewcontroller = newView;
            [newView release];
            newviewcontroller.currentPageName =self.currentpagename;
            newviewcontroller.rightPageName =rightpagename;
            newviewcontroller.leftPageName =leftpagename;
            NSMutableArray* mutableArray = [[NSMutableArray alloc]init];
            newviewcontroller.controlType = mutableArray;
            [mutableArray release];
            if (self.newviewcontroller)
            {
                //页面背景信息设置
                UIImageView *backgroundImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight)]autorelease];
                if (![backgroundImage isEqualToString:@""])
                {
                    backgroundImage = [imageSourcePath stringByAppendingPathComponent:backgroundImage];
                    NSData* backgroundImageData=[NSData dataWithContentsOfFile:backgroundImage];
                    UIImage* img=[UIImage imageWithData:backgroundImageData];
                    [backgroundImageView setImage:img];
                    [newviewcontroller.view addSubview:backgroundImageView];
                }
                else if(backgroundColor)
                {
                    [newviewcontroller.view setBackgroundColor:[ParserXMLService colorWithHexString:backgroundColor]];
                }
                
                //解析子控件
                NSArray *elementArry = [ele children];
                if (elementArry)
                {
                    int counts=[elementArry count];
                    //NSLog(@"lpAry is %d",counts);
                    for (int i=0; i<counts; i++)
                    {
                        GDataXMLElement * tmp = [elementArry objectAtIndex:i];
                        NSString *strTag = [tmp name];
                        [newviewcontroller.controlType addObject:strTag];
                        if([strTag isEqualToString: CONTROL_TYPE_IMAGE])
                        {
                            PHButton *image = [[PHButton alloc] initWithType:1];
                            if(image)
                            {
                                [image ParserXML:tmp];
                                if ([image.action isEqualToString:@"1"]) {
                                    [UIView beginAnimations:@"movement" context:nil];
                                    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                                    [UIView setAnimationDuration:1.0f];
                                    [UIView setAnimationRepeatCount:0.5];
                                    [UIView setAnimationRepeatAutoreverses:YES];
                                    float y =770-image.center.y;
                                    NSLog(@"image.center.y====%f",image.center.y);
                                    image.center=CGPointMake(image.center.x, image.center.y+y);
                                    CGPoint center=image.center;
                                    if (image.center.y>768) {
                                        center.y -=y;
                                        image.center=center;
                                    }
                                    [UIView commitAnimations];
                                    
                                    [newviewcontroller.view addSubview:image];
                                    [self performSelector:@selector(Animate:) withObject:image afterDelay:1.0];
                                    
                                }else{
                                    [newviewcontroller.view addSubview:image];
                                }
                                
                                [image release];
                            }
                        }
                        else if([strTag isEqualToString: CONTROL_TYPE_BUTTON])
                        {
                            PHButton *button = [[PHButton alloc] init];
                            
                            if(button)
                            {
                                [button ParserXML:tmp];
                                [newviewcontroller.view addSubview:button];
                                [button release];
                            }
                        }
                        else if([strTag isEqualToString: CONTROL_TYPE_SLIDER])
                        {
                            
                            //Slider
                            PHSlider *slider = [[PHSlider alloc] init];
                            
                            if(slider)
                            {
                                [slider ParserXML:tmp];
                                
                                [newviewcontroller.view addSubview:slider];
                                [slider release];
                            }
                        }
                        else if([strTag isEqualToString: CONTROL_TYPE_LABEL])
                        {
                            PHLabel *label=[[PHLabel alloc]init];
                            if (label) {
                                [label ParserXML:tmp];
                                [newviewcontroller.view addSubview:label];
                                [label release];
                            }
                        }
                        else if([strTag isEqualToString: CONTROL_TYPE_CheckBox])
                        {
                            CheckBox *checkbox = [[CheckBox alloc] initwithDelegate:self];
                            if (checkbox) {
                                [checkbox ParserXML:tmp];
                                [newviewcontroller.view addSubview:checkbox];
                                [checkbox release];
                            }
                        }
                        else if ([strTag isEqualToString:CONTROL_TYPE_RadioBox])
                        {
                            RadioBox *radioBox=[[RadioBox alloc] initwithDelegate:self];
                            if (radioBox) {
                                
                                [radioBox ParserXML:tmp];
                                [newviewcontroller.view addSubview:radioBox];
                                [radioBox release];
                            }
                        }
                        else if([strTag isEqualToString: CONTROL_TYPE_Progress])
                        {
                            
                            //Progress
                            PHProgress *progress = [[PHProgress alloc]init];
                            if (progress) {
                                [progress ParserXML:tmp];
                                
                                [newviewcontroller.view addSubview:progress];
                                
                                [progress release];
                            }
                        }
                        
                    }
                    
                }
                
                //处理待处理事件
                [self dealwithPendingEvents:newviewcontroller];
                
                //将解析页面显示出来
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UINavigationController *navigCon = appDelegate.NavCon;
                //                [navigCon dismissModalViewControllerAnimated:NO];
                [navigCon dismissViewControllerAnimated:NO completion:^{
                }];
                [navigCon presentViewController:newviewcontroller animated:NO completion:^{
                }];
                newviewcontroller.pageCount = pageidcount;
                //                [newviewcontroller release];
                
            }
        }
    }
}

-(void)Animate:(PHButton *)image
{
    CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    //设置抖动幅度
    shake.fromValue = [NSNumber numberWithFloat:-0.1];
    
    shake.toValue = [NSNumber numberWithFloat:+0.1];
    
    shake.duration = 0.1;
    
    shake.autoreverses = YES; //是否重复
    
    shake.repeatCount = 4;
    
    [image.layer addAnimation:shake forKey:@"imageView"];
    
    image.alpha = 1.0;
    
    [UIView animateWithDuration:2.0 delay:2.0 options:UIViewAnimationOptionCurveEaseIn animations:nil completion:nil];
    
}

-(void)parserXmlWithName:(NSString*)name
{
    if(name)
    {
        NSData* dataXML = [NSData dataWithContentsOfFile:self.xmlFilePath];
        
        //对NSData对象初始化
        NSError* error=nil;
        GDataXMLDocument* gdataXMLDoc = [[[GDataXMLDocument alloc] initWithData:dataXML options:0
                                                                          error:&error] autorelease];
        GDataXMLElement * rootElement = [gdataXMLDoc rootElement];
        NSArray *elementArry = [rootElement elementsForName:XML_HMUI_ATTR];
        //        NSLog(@"%d", [elementArry count]);
        if (elementArry)
        {
            int nHmuiCounts = [elementArry count];
            pageidcount =nHmuiCounts;
            for (int i=0; i < nHmuiCounts; i++)
            {
                GDataXMLElement * tmp = [elementArry objectAtIndex:i];
                
                /*HMUI的属性*/
                NSString* newName = [[tmp attributeForName:XML_NAME_ATTR] stringValue];
                
                if([newName isEqualToString: name])
                {
                    self.currentpagename=newName;
                    
                    rightpagename=[[tmp attributeForName:XML_RIGHTPOPUPPAGE_ATTR]stringValue];
                    
                    leftpagename=[[tmp attributeForName:XML_LEFTPOPUPPAGE_ATTR] stringValue];
                    
                    
                    [self parserXmlWithDocument:tmp];
                    
                    
                    return;
                }
            }
            //到这说明失败了
        }
        
    }
}
//待处理事件
-(void)dealwithPendingEvents:(PageViewController*)controller
{
    if(controller)
    {
        int nCounts = [self.eventsArray count];
        BOOL bRet = NO;
        for(int i = 0;i<nCounts;i++)
        {
            NSString * event = [self.eventsArray objectAtIndex:i];
            bRet = [self dealwithEventsinView:controller withEvent:event];
            if(bRet == YES)
            {
                [self.eventsArray removeObjectAtIndex:i];
                nCounts--;
                i--;
            }
            
        }
    }
}
//处理当前页面事件
-(void)dealwithEventsInPresentedView:(NSString*)event
{
    if(event){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *navigCon = appDelegate.NavCon;
        PageViewController *curViewController = (PageViewController *)[navigCon presentedViewController];
        if(curViewController)
        {
            BOOL bRet = [self dealwithEventsinView:curViewController withEvent:event];
            if (!bRet) {
                if(![self.eventsArray containsObject:event])
                    [self.eventsArray addObject:event]; //若没有处理完成,保存该事件等候处理
            }
            NSLog(@"event========%@",event);
        }
    }
}
//处理指定界面的事件(显示、隐藏、可用、禁用)
-(BOOL)dealwithEventsinView:(PageViewController*)controller withEvent:(NSString*)event
{
    BOOL bRet = NO;
    if(controller && event)
    {
        NSArray* myarray=[event componentsSeparatedByString:SEPARATOR_SEMICOLONT];//分割字符串
        if([myarray count] == 2)
        {
            NSString *strEvent=nil,*strObject=nil,*strControlType=nil;
            int nControlId;
            strEvent = [myarray objectAtIndex:0];
            strObject = [myarray objectAtIndex:1];
            NSArray* controlNameArray=[strObject componentsSeparatedByString:SEPARATOR_UNDERLINE];
            strControlType = [controlNameArray objectAtIndex:0];
            nControlId = [[controlNameArray objectAtIndex:1] intValue];
            
            UIView * controlView = [controller.view viewWithTag:nControlId];
            if(controlView)
            {
                bRet = YES;
                if([strControlType isEqualToString:CONTROL_TYPE_BUTTON]
                   || [strControlType isEqualToString:CONTROL_TYPE_IMAGE]){
                    PHButton *button =(PHButton*)controlView;
                    if([strEvent isEqualToString:METHOD_SHOW])
                    {
                        [button setHidden:NO];
                    }else if([strEvent isEqualToString:METHOD_HIDE]){
                        [button setHidden:YES];
                    }else if([strEvent isEqualToString:METHOD_ENABLE])
                    {
                        [button setEnabled:YES];
                    }else if([strEvent isEqualToString:METHOD_UNABLE]){
                        [button setEnabled:NO];
                    }
                }else if([strControlType isEqualToString:CONTROL_TYPE_SLIDER]){
                    
                    PHSlider *slider =(PHSlider*)controlView;
                    
                    if([strEvent isEqualToString:METHOD_SHOW])
                    {
                        [slider setHidden:NO];
                    }else if([strEvent isEqualToString:METHOD_HIDE]){
                        [slider setHidden:YES];
                    }else if([strEvent isEqualToString:METHOD_ENABLE])
                    {
                        [slider setEnabled:YES];
                    }else if([strEvent isEqualToString:METHOD_UNABLE]){
                        [slider setEnabled:NO];
                    }
                    
                }
            }
        }
        
    }
    
    return bRet;
}


#pragma mark - QCheckBoxDelegate

- (void)didselectedCheckBox:(CheckBox *)checkbox checked:(BOOL)checked {
    NSLog(@"did tap on CheckBox:%@ checked:%d", checkbox.titleLabel.text, checked);
}

- (void)didselectedRadioBox:(RadioBox *)radiobox checked:(BOOL)checked {
    
    NSLog(@"did tap on CheckBox:%@ checked:%d", radiobox.titleLabel.text, checked);
}


-(void)dealloc{
    [super dealloc];
    [_projectName release];
    [_startPage release];
    [_xmlFilePath release];
    [_eventsArray release];
}
@end
