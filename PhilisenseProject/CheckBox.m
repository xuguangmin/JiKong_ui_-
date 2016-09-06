//
//  CheckBox.m
//  飞利信集控
//
//  Created by flxlq on 14-2-11.
//
//

#import "CheckBox.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"
#import "PageViewController.h"

#define CHECK_ICON_WH                   (15.0)
#define ICON_TITLE_MARGIN               (5.0)
@implementation CheckBox
@synthesize  delegate = _delegate;
@synthesize  checked = _checked;
@synthesize  userInfo = _userInfo;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.clickEventDirectory = [NSMutableDictionary dictionary];
        self.pressedEventDirectory = [NSMutableDictionary dictionary];
        self.releasedEventDirectory = [NSMutableDictionary dictionary];
        _nType = 0;
    }
    return self;
}
//重载初始化函数
-(id)initWithType:(int)type
{
    self = [self init];
    _nType = type;
    return self;
}


-(id)initwithDelegate:(id)delegate{
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.exclusiveTouch = YES;
        [self setImage:[UIImage imageNamed:@"checkbox1_unchecked.png"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"checkbox1_checked.png"] forState:UIControlStateSelected];
        [self addTarget:self action:@selector(checkboxBtnChecked) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(checkboxBtnPressed) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setChecked:(BOOL)checked{
    if (_checked == checked) {
        return ;
    }
    _checked = checked;
    self.selected = checked;
    if (_delegate && [_delegate respondsToSelector:@selector(didselectedCheckBox:checked:)]) {
        [_delegate didselectedCheckBox:self checked:self.selected];
    }
}

- (IBAction)checkboxBtnChecked {
    self.selected = !self.selected;
    _checked = self.selected;
    if (_delegate && [_delegate respondsToSelector:@selector(didselectedCheckBox:checked:)]) {
        [_delegate didselectedCheckBox:self checked:self.selected];
    }
}
- (IBAction)checkboxBtnPressed {
    
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    return CGRectMake(0, (CGRectGetHeight(contentRect) - CHECK_ICON_WH)/2.0,CHECK_ICON_WH, CHECK_ICON_WH);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    return CGRectMake(CHECK_ICON_WH + ICON_TITLE_MARGIN, 0, CGRectGetWidth(contentRect) - CHECK_ICON_WH - ICON_TITLE_MARGIN, CGRectGetHeight(contentRect));
}

- (void)dealloc {
    self.userInfo = nil;
    self.delegate = nil;
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

-(void)ParserXML:(GDataXMLElement*)elementy//解析ButtonControl节点
{
    if(elementy){
        self.controlId = [[elementy attributeForName:XML_ID_ATTR] stringValue] ;//获取节点的Id属性
        self.action = [[elementy attributeForName:XML_ACTION_ATTR]stringValue];
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
        if(geometry)
        {
            geometry = [geometry stringByReplacingOccurrencesOfString:@"(" withString:@""];
            geometry = [geometry stringByReplacingOccurrencesOfString:@")" withString:@""];
            NSArray* myarray = [geometry componentsSeparatedByString:@","];//分割字符串
            CGFloat f[4] = {0,0,0,0};
            int nCount = [myarray count];
            for (int i = 0; i < nCount; i++) {
                f[i] = [[myarray objectAtIndex:i] floatValue];//将NSString类型转换成Float类型
            }
            
            //根据页面和屏幕的比例设置控件的位置和大小
            ParserXMLService *parserXMLService = [ParserXMLService sharedParserXMLService];
            if(parserXMLService)
            {
                f[0] = f[0] * parserXMLService.hRatio;
                f[1] = f[1] * parserXMLService.cRatio;
                f[2] = f[2] * parserXMLService.hRatio;
                f[3] = f[3] * parserXMLService.cRatio;
            }else
            {
                return;
            }
            [self setFrame:CGRectMake(f[0],f[1],f[2],f[3])];
        }
        
        //设备背景色
        [self setBackgroundColor:[UIColor clearColor]];        //设置前景色
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
                fontstyle=@"SimSun";
                self.titleLabel.font = [UIFont fontWithName:fontstyle size:fontsize];
            }else{
                self.titleLabel.font = [UIFont systemFontOfSize:fontsize];
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
        for(int i = 0; i < nCounts;i++)
        {
            GDataXMLElement *childElement = (GDataXMLElement *)[eventElementy childAtIndex:i];
            nChildCounts = [childElement childCount];
            NSString *strEventType = [childElement name];
            NSString *strEvent,*strObject;
            GDataXMLElement *methodElement = nil;
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

//发送单击和释放事件
-(void)onClickEvent
{
    //获取节点的PopupPage属性
    /*if (self.popupPage)
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
    }*/
}

//发送按下事件
-(void)onPressedDownEvent
{
    /*[self dealwithEvents:1];
    
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
    }*/
}

//处理事件(紧对控件的)
-(void)dealwithEvents:(int)type
{
    /*ParserXMLService *parseXmlService = [ParserXMLService sharedParserXMLService];
    if(parseXmlService){
        NSArray * array = nil;
        if (type == 0) {
            array = [self.clickEventDirectory allValues];
            NSLog(@"");
        }else if(type == 1)
        {
            array = [self.pressedEventDirectory allValues];
            NSLog(@"");
        }else if(type == 2){
            array = [self.releasedEventDirectory allValues];
            NSLog(@"");
        }
        
        for(NSString *strValue in array)
        {
            if(strValue)
                [parseXmlService dealwithEventsInPresentedView:strValue];
        }
    }*/
}

@end
