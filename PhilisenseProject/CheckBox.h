//
//  CheckBox.h
//  飞利信集控
//
//  Created by flxlq on 14-2-11.
//
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;
@protocol CheckBoxDelegate;

@interface CheckBox : UIButton{
    id<CheckBoxDelegate>_delegate;
    BOOL _checked;
    id _userInfo;
    
    NSMutableDictionary *_clickEventDirectory;
    NSMutableDictionary *_pressedEventDirectory;
    NSMutableDictionary *_releasedEventDirectory;
    
    int _nType; //标示CheckBox   0标示CheckBox，1标示RadioBox
}
@property(assign, nonatomic) id<CheckBoxDelegate>delegate;
@property(assign, nonatomic) BOOL checked;
@property(retain, nonatomic) id userInfo;

@property (strong, nonatomic) NSString *popupPage;
@property (strong, nonatomic) NSString *controlId;
@property (strong, nonatomic) NSString *action;
@property (strong, nonatomic) NSString *strForgroundColor;
@property (strong, nonatomic) NSString *strForgroundColorForPressed;
@property (strong, nonatomic) NSString *strBackgroundColor;
@property (strong, nonatomic) NSString *strBackgroundColorForPressed;

@property (strong, nonatomic) NSMutableDictionary *clickEventDirectory;
@property (strong, nonatomic) NSMutableDictionary *pressedEventDirectory;
@property (strong, nonatomic) NSMutableDictionary *releasedEventDirectory;
@property (assign, nonatomic) int zIndex;
@property (assign, nonatomic) int nVisible;
@property (assign, nonatomic) int nEnable;

- (id)initwithDelegate:(id)delegate;
-(void)ParserXML:(GDataXMLElement*)elementy;
-(void)dealwithEventsFromXml:(GDataXMLElement*)elementy;
-(void)dealwithEvents:(int)type;    //type 标示类型0标示单击事件,1标示按下事件,2表示释放事件
-(void)onClickEvent;
-(void)onPressedDownEvent;

@end
@protocol CheckBoxDelegate <NSObject>

@optional
- (void)didselectedCheckBox:(CheckBox *)checkbox checked:(BOOL)checked;
@end