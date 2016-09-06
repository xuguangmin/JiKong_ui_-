//
//  PHImage.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;

@interface PHImage : UIImageView
{
    NSString * _popupPage;
    NSString * _controlId;
    int _zIndex;
    int _nVisible;
    int _nEnable;
}
@property (strong,nonatomic) NSString *popupPage;
@property (strong,nonatomic) NSString *controlId;
@property (nonatomic) int zIndex;
@property (nonatomic) int nVisible;
@property (nonatomic) int nEnable;


-(void)ParserButtonXML:(GDataXMLElement*)elementy;
//点击HMUI下的控件所触发的事件
-(void)onClickEvent;
@end
