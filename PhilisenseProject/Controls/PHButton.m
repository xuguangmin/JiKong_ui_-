//
//  PHButton.m
//  philisenseProject
//
//  Created by flx flx on 12-10-8.
//  Copyright 2012年 flx. All rights reserved.
//
#import "PHButton.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"
#import "PageViewController.h"

@implementation PHButton

@synthesize clickEventDirectory = _clickEventDirectory;
@synthesize pressedEventDirectory = _pressedEventDirectory;
@synthesize releasedEventDirectory = _releasedEventDirectory;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.clickEventDirectory = [NSMutableDictionary dictionary];
        self.pressedEventDirectory = [NSMutableDictionary dictionary];
        self.releasedEventDirectory = [NSMutableDictionary dictionary];
        _bHasImage = NO;
        _nType = 0;
        
    }
    return self;
}
//重载初始化函数
-(id)initWithType:(int)type
{
    self = [self init];
    if(self)
    {
        _nType = type;
    }
    return self;
}

-(void)dealloc{
    self.popupPage = nil;
    self.controlId = nil;
    self.strForgroundColor = nil;
    self.strForgroundColorForPressed = nil;
    self.strBackgroundColor = nil;
    self.strBackgroundColorForPressed = nil;
    
    self.clickEventDirectory = nil;
    self.pressedEventDirectory = nil;
    self.releasedEventDirectory = nil;
    
    [super dealloc];
}
-(void)ParserXML:(GDataXMLElement*)elementy //解析ButtonControl节点
{
    if(elementy){
        SocketServices *socketServer = [SocketServices sharedSocketServices];
        if(nil == socketServer)
            return;
        
        NSString *imageSourcePath = [socketServer.xmlSourcePath
                                     stringByAppendingPathComponent:IMAGE_RESOURCE];
        
        self.Warning = [[[elementy attributeForName:XML_WARINING_ATTR] stringValue] intValue];
        self.controlId = [[elementy attributeForName:XML_ID_ATTR] stringValue] ;//获取节点的Id属性
        self.action =[[elementy attributeForName:XML_ACTION_ATTR]stringValue];
        self.waringText=[[elementy attributeForName:XML_WARININGTEXT_ATTR] stringValue];
        self.zIndex = [[[elementy attributeForName:XML_Z_INDEX_ATTR] stringValue] intValue];
        self.nVisible = [[[elementy attributeForName:XML_VISIBLE_ATTR] stringValue] intValue];
        self.nEnable = [[[elementy attributeForName:XML_ENABLE_ATTR] stringValue] intValue];
        
        self.popupPage = [[elementy attributeForName:XML_POPUPPAGE_ATTR] stringValue];
        self.strForgroundColor = [[elementy attributeForName:XML_FOREGROUNDCOLOR_ATTR] stringValue];
        self.strForgroundColorForPressed = [[elementy attributeForName:XML_FOREGROUNDCOLOR_ATTR] stringValue];
        self.strBackgroundColor = [[elementy attributeForName:XML_BACKGROUNDCOLOR_ATTR] stringValue];
        self.strBackgroundColorForPressed = [[elementy attributeForName:XML_BACKGROUNDCOLOR_ATTR] stringValue];
        
        //设置坐标
        NSString* geometry = [[elementy attributeForName:XML_GEOMETRY_ATTR] stringValue];//获取节点的geometry属性
        //根据页面和屏幕的比例设置控件的位置和大小
        ParserXMLService *parserXMLService = [ParserXMLService sharedParserXMLService];
        
        if(geometry)
        {
            geometry = [geometry stringByReplacingOccurrencesOfString:@"(" withString:@""];
            geometry = [geometry stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSArray* myarray = [geometry componentsSeparatedByString:@","];//分割字符串
            CGFloat f[4] = {0,0,0,0};
            int nCount = [myarray count];
            NSString* strValue;
            for (int i = 0; i < nCount; i++) {
                strValue = [myarray objectAtIndex:i];
                f[i] = [strValue floatValue];//将NSString类型转换成Float类型
            }
            
            
            if(parserXMLService)
            {
                f[0] = f[0] * parserXMLService.hRatio;
                f[1] = f[1] * parserXMLService.cRatio;
                f[2] = f[2] * parserXMLService.hRatio;
                f[3] = f[3] * parserXMLService.cRatio;
            }
            [self setFrame:CGRectMake(f[0],f[1],f[2],f[3])];
        }
        
        //设置普通状态背景图片
        NSString* backgroundImage = [[elementy attributeForName:XML_BACKGROUNDIMAGE_ATTR] stringValue];
        if (backgroundImage) {
            backgroundImage = [imageSourcePath stringByAppendingPathComponent:backgroundImage];
            NSData* backgroundImageData = [NSData dataWithContentsOfFile:backgroundImage];
            UIImage* img = [UIImage imageWithData:backgroundImageData];
            [self setBackgroundImage:img forState:UIControlStateNormal];
            _bHasImage = YES;
        }
        //设置按下状态背景图片
        NSString* backgroundImage_pressed = [[elementy attributeForName:
                                              XML_BACKGROUNDIMAGE_PRESSED_ATTR] stringValue];
        if(backgroundImage_pressed){
            backgroundImage_pressed = [imageSourcePath stringByAppendingPathComponent:backgroundImage_pressed];
            NSData* backgroundImageData = [NSData dataWithContentsOfFile:backgroundImage_pressed];
            UIImage* img = [UIImage imageWithData:backgroundImageData];
            [self setBackgroundImage:img forState:UIControlStateHighlighted];
            _bHasImage = YES;
        }
        
        //设备背景色
        if(!_bHasImage){
            if(!self.strBackgroundColor)
                self.strBackgroundColor = DEFAULT_BACKGROUND_COLOR;
            
            if(!self.strBackgroundColorForPressed)
                self.strBackgroundColorForPressed = DEFAULT_BACKGROUND_PRESSED_COLOR;
            
            [self setBackgroundColor:[ParserXMLService colorWithHexString:self.strBackgroundColor]];
        } else {
            [self setBackgroundColor:[UIColor clearColor]];
        }
        //设置前景色
        if(!self.strForgroundColor)
            self.strForgroundColor = DEFAULT_FOREGROUND_COLOR;
        
        if(!self.strForgroundColorForPressed)
            self.strForgroundColorForPressed = DEFAULT_FOREGROUND_PRESSED_COLOR;
        
        [self setTitleColor:[ParserXMLService colorWithHexString:self.strForgroundColor] forState:UIControlStateNormal];
        [self setTitleColor:[ParserXMLService colorWithHexString:self.strForgroundColorForPressed] forState:UIControlStateHighlighted];
        
        //显示文本
        NSString* text = [[elementy attributeForName:XML_TEXT_ATTR] stringValue];//获取节点的Text属性
        NSString* fontstyle = [[elementy attributeForName:XML_FONT_ATTR] stringValue];
        float fontsize = [[[elementy attributeForName:XML_FONTSIZE_ATTR] stringValue] floatValue];
        if (text)
        {
            [self setTitle:text forState:UIControlStateNormal];
            if ([fontstyle isEqualToString:@"宋体"]) {
                //                fontstyle=@"SimSun";
                self.titleLabel.font = [UIFont fontWithName:fontstyle size:fontsize*parserXMLService.hRatio];
                
            }else{
                self.titleLabel.font = [UIFont systemFontOfSize:fontsize*parserXMLService.hRatio-1];
            }
        }
        
        //可用和可见属性
        if(self.nEnable == 0)
            [self setEnabled:NO];
        if(self.nVisible == 0)
            [self setHidden:YES];
        
        
        //设置标签
        [self setTag:[self.controlId intValue]];
        [self dealwithEventsFromXml:elementy];
        
        //添加事件
        [self addTarget:self action:@selector(onClickEvent) forControlEvents:UIControlEventTouchUpInside];
        
        [self addTarget:self action:@selector(onPressedDownEvent) forControlEvents:UIControlEventTouchDown];
        
    }
}


-(void)dealwithEventsFromXml:(GDataXMLElement*)elementy
{
    //事件处理
    int nCounts = [elementy childCount];
    int nChildCounts = 0;
    int nObjectCount = 0;
    if(nCounts > 0)
    {
        GDataXMLElement * eventElementy = (GDataXMLElement *)[elementy childAtIndex:0];
        nCounts =  [eventElementy childCount];
        for(int i = 0; i < nCounts; i++)
        {
            GDataXMLElement *childElement = (GDataXMLElement *)[eventElementy childAtIndex:i];
            NSString *strEventType = [childElement name];
            NSString *strEvent,*strObject;
            GDataXMLElement *methodElement = nil;
            nChildCounts = [childElement childCount];
            for(int j = 0;j < nChildCounts; j++)
            {
                methodElement = (GDataXMLElement *)[childElement childAtIndex:j];
                strEvent = [[methodElement attributeForName:XML_EVENT_ATTR] stringValue];
                strObject = [[methodElement attributeForName:XML_OBJECT_ATTR] stringValue];
                if([strEventType isEqualToString:XML_CLICK_ATTR])//单击事件
                {
                    nObjectCount = [self.clickEventDirectory count];
                    [self.clickEventDirectory setObject:[NSString stringWithFormat:@"%@%@%@",strEvent,SEPARATOR_SEMICOLONT,strObject] forKey:[NSString stringWithFormat:@"%d",nObjectCount]];
                    
                }else if([strEventType isEqualToString:XML_PRESSED_ATTR])//按下事件
                {
                    nObjectCount = [self.pressedEventDirectory count];
                    [self.pressedEventDirectory setObject:[NSString stringWithFormat:@"%@%@%@",strEvent,SEPARATOR_SEMICOLONT,strObject] forKey:[NSString stringWithFormat:@"%d",nObjectCount]];
                    
                }else if([strEventType isEqualToString:XML_RELEASED_ATTR])//释放事件
                {
                    nObjectCount = [self.releasedEventDirectory count];
                    [self.releasedEventDirectory setObject:[NSString stringWithFormat:@"%@%@%@",strEvent,SEPARATOR_SEMICOLONT,strObject] forKey:[NSString stringWithFormat:@"%d",nObjectCount]];
                }
            }
        }
    }
    
}

- (void)onClickEvent
{
    if (self.Warning==1) {
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil message:self.waringText delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alert show];
    }
    else{
        
        [self doClickEvent];
    }
    
}
//发送单击和释放事件
-(void)doClickEvent
{
    
    //重置背景色
    if(!_bHasImage)
    {
        [self setBackgroundColor:[ParserXMLService colorWithHexString:self.strBackgroundColor]];
    }
    
    //获取节点的PopupPage属性
    if (self.popupPage)
    {
        ParserXMLService *parserXMLServer = [ParserXMLService sharedParserXMLService];
        if(parserXMLServer)
        {
            [parserXMLServer parserXmlWithName:self.popupPage];
        }
    }
    
    [self dealwithEvents:0];
    [self dealwithEvents:2];
    
    
    //通知服务器单击事件
    SocketServices *socketService = [SocketServices sharedSocketServices];
    if(socketService)
    {
        
        if(_nType == 0){    //按钮事件
            //按钮弹起事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_BUTTON_RELEASED];
            //按钮单击事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_BUTTON_CLICK];
            
        }else if(_nType == 1){  //图片事件
            //图片弹起事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_IMAGE_RELEASED];
            //图片单击事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_IMAGE_CLICK];
        }
    }
    
    
}

#pragma mark AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex!=[alertView cancelButtonIndex]) {
        
        [self doClickEvent];
    }
    
}


//发送按下事件
-(void)onPressedDownEvent
{
    //重置背景色
    if(!_bHasImage)
    {
        [self setBackgroundColor:[ParserXMLService colorWithHexString:self.strBackgroundColorForPressed]];
    }
    
    [self dealwithEvents:1];
    
    //通知服务器单击事件
    SocketServices *socketService = [SocketServices sharedSocketServices];
    if(socketService)
    {
        if(_nType == 0){    //按钮事件
            
            //按钮弹起事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_BUTTON_PRESSED];
        }else if(_nType == 1){  //图片事件
            //图片弹起事件
            [socketService sendControlEvent:self.controlId withEventType:EVENT_IMAGE_PRESSED];
        }
    }
    
}

//处理事件(紧对控件的)
-(void)dealwithEvents:(int)type
{
    ParserXMLService *parseXmlService = [ParserXMLService sharedParserXMLService];
    if(parseXmlService){
        NSArray * array = nil;
        if (type == 0) {
            if([self.clickEventDirectory count] > 0)
                array = [self.clickEventDirectory allValues];
        }else if(type == 1)
        {
            if([self.pressedEventDirectory count] > 0)
                array = [self.pressedEventDirectory allValues];
        }else if(type == 2){
            if([self.releasedEventDirectory count] > 0)
                array = [self.releasedEventDirectory allValues];
        }
        
        for(NSString *strValue in array)
        {
            if(strValue)
                [parseXmlService dealwithEventsInPresentedView:strValue];
        }
    }
}

@end
