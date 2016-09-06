//
//  PHButton.h
//  philisenseProject
//
//  Created by flx flx on 12-10-8.
//  Copyright 2012年 flx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;

@interface PHButton : UIButton<UIAlertViewDelegate>
{
    NSMutableDictionary* _clickEventDirectory;
    NSMutableDictionary* _pressedEventDirectory;
    NSMutableDictionary* _releasedEventDirectory;
    
    BOOL _bHasImage;    //标识是否有图
    int _nType; //标示按钮还是图片  0标示按钮，1标示图片
}
@property (strong, nonatomic) NSString* popupPage;
@property (strong, nonatomic) NSString* controlId;
@property (strong, nonatomic) NSString* action;
@property (strong, nonatomic) NSString* strForgroundColor;
@property (strong, nonatomic) NSString* strForgroundColorForPressed;
@property (strong, nonatomic) NSString* strBackgroundColor;
@property (strong, nonatomic) NSString* strBackgroundColorForPressed;
@property (strong, nonatomic) NSString* waringText;

@property (strong, nonatomic) NSMutableDictionary* clickEventDirectory;
@property (strong, nonatomic) NSMutableDictionary* pressedEventDirectory;
@property (strong, nonatomic) NSMutableDictionary* releasedEventDirectory;
@property (assign, nonatomic) int zIndex;
@property (assign, nonatomic) int nVisible;
@property (assign, nonatomic) int nEnable;

@property (assign, nonatomic) int Warning; //1表示有弹出事件   //0没有

- (id)initWithType:(int)type;

- (void)ParserXML:(GDataXMLElement*)elementy;
- (void)dealwithEventsFromXml:(GDataXMLElement*)elementy;
- (void)dealwithEvents:(int)type;    //type 标示类型0标示单击事件,1标示按下事件,2表示释放事件
- (void)onClickEvent;

- (void)onPressedDownEvent;

@end
