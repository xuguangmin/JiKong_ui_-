//
//  PHLabel.m
//  PhilisenseProject
//
//  Created by flxlq on 13-5-22.
//
//

#import "PHLabel.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"
#import "PageViewController.h"

@implementation PHLabel

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)dealloc
{
    self.strForgroundColor = nil;
    self.strBackgroundColor = nil;
    
    [super dealloc];
}

-(void)ParserXML:(GDataXMLElement*)elementy{
    if(elementy)
    {
        self.zIndex = [[[elementy attributeForName:XML_Z_INDEX_ATTR] stringValue] intValue];
        self.nVisible = [[[elementy attributeForName:XML_VISIBLE_ATTR] stringValue] intValue];
        self.nEnable = [[[elementy attributeForName:XML_ENABLE_ATTR] stringValue] intValue];
        self.nAlignment = [[[elementy attributeForName:XML_TEXTALIGN_ATTR] stringValue] intValue];
        self.strForgroundColor = [[elementy attributeForName:XML_FOREGROUNDCOLOR_ATTR] stringValue];
        self.strBackgroundColor = [[elementy attributeForName:XML_BACKGROUNDCOLOR_ATTR] stringValue];
        
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
                f[i] = [[myarray objectAtIndex:i] floatValue]; //将NSString类型转换成Float类型
            }
            
            //根据页面和屏幕的比例设置控件的位置和大小
            ParserXMLService *parserXMLService = [ParserXMLService sharedParserXMLService];
            if(parserXMLService){
                f[0] = f[0] * parserXMLService.hRatio;
                f[1] = f[1] * parserXMLService.cRatio;
                f[2] = f[2] * parserXMLService.hRatio;
                f[3] = f[3] * parserXMLService.cRatio;
            }
            
            [self setFrame:CGRectMake(f[0],f[1],f[2],f[3])];
            //设置背景颜色
            if (self.strBackgroundColor) {
                [self setBackgroundColor:[ParserXMLService colorWithHexString:self.strBackgroundColor]];
            }else{
                [self setBackgroundColor:[UIColor clearColor]];
            }
            
            //设置前景色即字体颜色
            if(!self.strForgroundColor){
                self.strForgroundColor = DEFAULT_FOREGROUND_COLOR;
            }
            if (self.strForgroundColor) {
                [self setTextColor:[ParserXMLService colorWithHexString:self.strForgroundColor]];
            }
            
            //显示文本
            NSTextAlignment alignment = NSTextAlignmentCenter;
            if(self.nAlignment == TEXTALIGNMENTLEFT)
            {
                alignment = NSTextAlignmentLeft;
            }else if(self.nAlignment == TEXTALIGNMENTRIGHT)
            {
                alignment = NSTextAlignmentRight;
            }
            
            self.textAlignment = alignment;
            NSString* text = [[elementy attributeForName:XML_TEXT_ATTR] stringValue];//获取节点的Text属性
            NSString* fontstyle = [[elementy attributeForName:XML_FONT_ATTR] stringValue];
            float fontsize = [[[elementy attributeForName:XML_FONTSIZE_ATTR] stringValue]floatValue];
            if (text) {
                self.text = text;
                
                //                NSLog(@"text____________%@",text);
                if ([fontstyle isEqualToString:@"宋体"]) {
                    self.font = [UIFont fontWithName:@"SimSun"size:fontsize*parserXMLService.hRatio];
                }else{
                    self.font = [UIFont fontWithName:@"STKaiti"size:fontsize*parserXMLService.hRatio-1];
                }
                
                
            }
            
            //可用和可见属性
            if(self.nEnable == 0)
                [self setEnabled:NO];
            
            if(self.nVisible == 0)
                [self setHidden:YES];
        }
        
    }
}

@end
