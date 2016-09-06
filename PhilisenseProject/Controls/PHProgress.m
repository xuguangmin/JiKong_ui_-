//
//  PHProgress.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-13.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "PHProgress.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"

@implementation PHProgress
{
    UIImageView * _backgroundImageView;
    UIImageView * _foregroundImageView;
    CGFloat minimumForegroundWidth;
    CGFloat availableWidth;
}
- (id)initWithFrame:(CGRect)frame
{
    
    self=[super initWithFrame:frame];
    if (self) {
        
        _orientation=0;
        self.progressViewStyle=UIProgressViewStyleDefault;

    }
    return self;
}
//- (id)initWithFrame:(CGRect)frame backgroundImage:(UIImage *)backgroundImage foregroundImage:(UIImage *)foregroundImage
//{
//    self=[super initWithFrame:frame];
//
//    if (self) {
//        
//        _orientation = 0;
//        
//        
//        
//        UIEdgeInsets insets = foregroundImage.capInsets;
//        minimumForegroundWidth = insets.left + insets.right;
//        
//        availableWidth = self.bounds.size.width - minimumForegroundWidth;
//        
//
//    }
//    
//    return self;
//}
//
//
//
//- (void)setProgress:(double)progress
//{
//    _progress = progress;
//    
//    CGRect frame = _foregroundImageView.frame;
//    frame.size.width = roundf(minimumForegroundWidth + availableWidth * progress);
//    _foregroundImageView.frame = frame;
//}

-(void)dealloc{
    [self setControlId:nil];
    [super dealloc];
}

-(void)ParserXML:(GDataXMLElement*)elementy
{
    if(elementy){
        self.controlId = [[elementy attributeForName:XML_ID_ATTR] stringValue] ;//获取节点的Id属性
        self.orientation = [[[elementy attributeForName:XML_ORIENTATION_ATTR] stringValue] intValue];
        self.zIndex = [[[elementy attributeForName:XML_Z_INDEX_ATTR] stringValue] intValue];
        self.nVisible = [[[elementy attributeForName:XML_VISIBLE_ATTR] stringValue] intValue];
        self.nEnable = [[[elementy attributeForName:XML_ENABLE_ATTR] stringValue] intValue];
        self.nCurValue = [[[elementy attributeForName:XML_VALUE_ATTR] stringValue] intValue];
        
        //设置坐标
        NSString* geometry = [[elementy attributeForName:XML_GEOMETRY_ATTR] stringValue];//获取节点的geometry属性
        if(geometry)
        {
            geometry = [geometry stringByReplacingOccurrencesOfString:@"(" withString:@""];
            geometry = [geometry stringByReplacingOccurrencesOfString:@")" withString:@""];
            
            NSArray* myarray = [geometry componentsSeparatedByString:@","];//分割字符串
            CGFloat f[4] = {0,0,0,0};
            int nCount = [myarray count];
            for (int i=0; i < nCount; i++) {
                f[i] = [[myarray objectAtIndex:i] floatValue];//将NSString类型转换成Float类型
            }
            
            //根据页面和屏幕的比例设置控件的位置和大小
            ParserXMLService *parserXMLService = [ParserXMLService sharedParserXMLService];
            if(parserXMLService){
                f[0] = f[0] * parserXMLService.hRatio;
                f[1] = f[1] * parserXMLService.cRatio;
                f[2] = f[2] * parserXMLService.hRatio;
                f[3] = f[3] * parserXMLService.cRatio;
            }else
                return;
            
            //根据滑动条方向改变坐标
            if(self.orientation == 1)
            {
                CGFloat fX = (2*f[0] + f[2] - f[3])/2;
                CGFloat fY = (2*f[1] + f[3] - f[2])/2;
                [self setFrame:CGRectMake(fX,fY,f[3],f[2])];
                [self setTransform:CGAffineTransformMakeRotation(trangle(-90))];
                
            }else {

                [self setFrame:CGRectMake(f[0], f[1], f[2], f[3])];

            }
        }

        
        //设置当前值
        self.progress = 0.5;

        
        if(self.nVisible == 0)
            [self setHidden:NO];
        
        //设置标签
        [self setTag:[self.controlId intValue]];

    }
}

//值修改发送事件
-(void)onValueChangedEvent

{
    self.nCurValue = self.progress;
    
    //通知服务器单击事件
    SocketServices *socketService = [SocketServices sharedSocketServices];
    if(socketService)
    {
        //弹起事件
        Byte data[4];
        data[0] = self.nCurValue >> 24;
        data[1] = self.nCurValue >> 16;
        data[2] = self.nCurValue >> 8;
        data[3] = self.nCurValue;
        
        [socketService sendControlEvent:self.controlId withEventType:EVENT_PROCESSBAR_VALUE_CHANGED withData:data andDataLen:4];
    }
}


@end
