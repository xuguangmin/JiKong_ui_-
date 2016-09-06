//
//  PHImage.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "PHImage.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"

@implementation PHImage
@synthesize popupPage = _popupPage;
@synthesize controlId = _controlId;
@synthesize zIndex = _zIndex;
@synthesize nVisible = _nVisible;
@synthesize nEnable = _nEnable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)ParserButtonXML:(GDataXMLElement*)elementy//解析ButtonControl节点
{
    if(elementy){
        SocketServices *socketServer = [SocketServices sharedSocketServices];
        if(socketServer){
            NSString *imageSourcePath = [socketServer.xmlSourcePath stringByAppendingPathComponent:
                                         IMAGE_RESOURCE];
            
            self.controlId = [[elementy attributeForName:XML_ID_ATTR] stringValue] ;            //获取节点的Id属性
            self.zIndex = [[[elementy attributeForName:XML_Z_INDEX_ATTR] stringValue] intValue];//zIndex
            self.nVisible = [[[elementy attributeForName:XML_VISIBLE_ATTR] stringValue] intValue];
            self.nEnable = [[[elementy attributeForName:XML_ENABLE_ATTR] stringValue] intValue];
            self.popupPage = [[elementy attributeForName:XML_POPUPPAGE_ATTR] stringValue];  //跳转页

            NSString* Geometry = [[elementy attributeForName:XML_GEOMETRY_ATTR] stringValue];//获取节点的坐标属性            
            NSString* backgroundImage = [[elementy attributeForName:XML_BACKGROUNDIMAGE_ATTR] stringValue];
            NSString* backgroundImage_pressed = [[elementy attributeForName:XML_BACKGROUNDIMAGE_PRESSED_ATTR] stringValue];
            NSString* backgroundImage_focused = [[elementy attributeForName:XML_BACKGROUNDIMAGE_PRESSED_ATTR] stringValue];
            NSString* backgroundColor = [[elementy attributeForName:XML_BACKGROUNDCOLOR_ATTR] stringValue];
            
            bool bHasImage = NO;
            //设置普通状态背景图片
            if (backgroundImage) {
                backgroundImage = [imageSourcePath stringByAppendingPathComponent:backgroundImage];
                NSData* backgroundImageData=[NSData dataWithContentsOfFile:backgroundImage];
                UIImage* img=[UIImage imageWithData:backgroundImageData];
                [self setImage:img];
                bHasImage = YES;
            }
            //设置按下状态背景图片
            if(backgroundImage_pressed){
                backgroundImage_pressed = [imageSourcePath stringByAppendingPathComponent:backgroundImage_pressed];
                NSData* backgroundImageData=[NSData dataWithContentsOfFile:backgroundImage_pressed];
                UIImage* img=[UIImage imageWithData:backgroundImageData];
                [self setHighlightedImage:img];
                bHasImage = YES;
            }
            //设置获取焦点状态背景图片
            if(backgroundImage_focused){
                backgroundImage_focused = [imageSourcePath stringByAppendingPathComponent:backgroundImage_focused];
                NSData* backgroundImageData=[NSData dataWithContentsOfFile:backgroundImage_focused];
                UIImage* img=[UIImage imageWithData:backgroundImageData];
                [self setHighlightedImage:img];
                bHasImage = YES;
            }
            NSLog(@"geometry:%@",Geometry);
            //设置背景图片
            Geometry=[Geometry stringByReplacingOccurrencesOfString:@"(" withString:@""];
            Geometry=[Geometry stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSArray* myarray=[Geometry componentsSeparatedByString:@","];//分割字符串
            CGFloat f[4];
            for (int i=0; i<[myarray count]; i++) {
                f[i]=[[myarray objectAtIndex:i] floatValue];//将NSString类型转换成Float类型
            }
            
            [self setFrame:CGRectMake(f[0], f[1], f[2], f[3])];
            
            //设置背景色
            if(backgroundColor && bHasImage == NO)
            {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, f[2], f[3])];
                [label setBackgroundColor:[ParserXMLService colorWithHexString:backgroundColor]];
                [self addSubview:label];
                [label release];
            }
            
            [self setUserInteractionEnabled:YES];
            [self setMultipleTouchEnabled:NO];//一次只接收一个单独的触摸（该属性默认值为NO）
            UITapGestureRecognizer* t=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickEvent)];//手势
            t.numberOfTapsRequired=1;
            [self addGestureRecognizer:t];
            [t release];
            
            
            NSString* text = [[elementy attributeForName:XML_TEXT_ATTR] stringValue];//获取节点的Text属性
            //显示文本
            if (text) {
                NSString *strForegroundColor = [[elementy attributeForName:XML_FOREGROUNDCOLOR_ATTR] stringValue];
                NSString *strFont = [[elementy attributeForName:XML_FONT_ATTR] stringValue];
                CGFloat aFontSize = [[[elementy attributeForName:XML_FONTSIZE_ATTR] stringValue] floatValue];
                NSString *strTextAlign = [[elementy attributeForName:XML_TEXTALIGN_ATTR] stringValue];
                
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, f[2], f[3])];
                [label setBackgroundColor:[UIColor clearColor]];//设置为透明
                [label setText:text];
                if(strForegroundColor)
                    [label setTextColor:[ParserXMLService colorWithHexString:strForegroundColor]];
                if(strFont && aFontSize > 0)
                {
                    label.font = [UIFont fontWithName:strFont size:aFontSize];
                }
                
                if(strTextAlign)
                {
                    if([strTextAlign isEqualToString:@"33"] ||
                       [strTextAlign isEqualToString:@"129"] ||
                       [strTextAlign isEqualToString:@"65"] )
                        label.textAlignment = UITextAlignmentLeft;
                    else if([strTextAlign isEqualToString:@"34"] ||
                            [strTextAlign isEqualToString:@"130"] ||
                            [strTextAlign isEqualToString:@"66"] )
                        label.textAlignment = UITextAlignmentRight;
                    else {
                        label.textAlignment = UITextAlignmentCenter;
                    }
                }

                [self addSubview:label];
                [label release];
            }
        }
    }
}
-(void)onClickEvent;
{
    //获取节点的PopupPage属性
    if (self.popupPage) {
        NSLog(@"%@",self.popupPage);
        ParserXMLService *parserXMLServer = [ParserXMLService sharedParserXMLService];
        [parserXMLServer parserXmlWithName:self.popupPage]; 
    }
    
    //通知服务器单击事件
    SocketServices *socketService = [SocketServices sharedSocketServices];
    if(socketService)
    {
        Byte clickEvent[4] = {0x00,0x00,0x10,0x20};
        [socketService sendControlEvent:self.controlId withEventType:clickEvent];
    }
}
@end
