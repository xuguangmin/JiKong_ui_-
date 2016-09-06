

#import "PHSlider.h"
#import "GDataXMLNode.h"
#import "global.h"
#import "SocketServices.h"
#import "ParserXmlService.h"

@interface PHSlider ()

- (void)commonInit;
- (float)xForValue:(float)value;
- (float)valueForX:(float)x;
- (float)stepMarkerXCloseToX:(float)x;

- (void)updateTrackHighlight;                  // set up track images overlay according to currernt value

- (NSString *)valueStringFormat;                // form value string format with given decimal places
-(void)onValueChangedEvent;

@end

@implementation PHSlider
@synthesize value = _value;
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;
@synthesize continuous = _continuous;
@synthesize stepped = _stepped;
@synthesize decimalPlaces = _decimalPlaces;
@synthesize labelOnThumb = _labelOnThumb;
@synthesize labelAboveThumb = _labelAboveThumb;

#pragma mark - UIView methods
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        
        // Initialization code
        
        _orientation = 0;   //默认为水平
        
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}


- (void)layoutSubviews
{
    //重新布局
    //垂直的情况
    if (self.orientation==1) {
        
        _trackImageViewNormal.frame=CGRectMake((self.frame.size.height-self.silder_mainHeight)/2,(self.frame.size.width-self.silder_mainWidth)/2,self.silder_mainHeight,self.silder_mainWidth);
        _thumbImageView.frame=CGRectMake(0,0, self.silder_markHeight, self.silder_markWidth);
        
        //thumbcenter
        _thumbImageView.center = CGPointMake(self.silder_markHeight/2,self.silder_mainWidth/2);
        
    }else{
        
        _trackImageViewNormal.frame=CGRectMake((self.frame.size.width-self.silder_mainWidth)/2, (self.frame.size.height-self.silder_mainHeight)/2, self.silder_mainWidth, self.silder_mainHeight);
        
        _thumbImageView.frame=CGRectMake((self.frame.size.width-self.silder_mainWidth)/2,0, self.silder_markWidth, self.silder_markHeight);
        _thumbImageView.center = CGPointMake(self.silder_markWidth/2, self.silder_mainHeight/2);
        
    }
    
    // the labels
    _labelOnThumb.frame = _thumbImageView.frame;
    _labelAboveThumb.frame = CGRectMake(_labelOnThumb.frame.origin.x, _labelOnThumb.frame.origin.y - _labelOnThumb.frame.size.height * 0.6f, _labelOnThumb.frame.size.width, _labelOnThumb.frame.size.height);
    
}


- (void)drawRect:(CGRect)rect
{
    _labelOnThumb.center = _thumbImageView.center;
    _labelAboveThumb.center = CGPointMake(_thumbImageView.center.x, _thumbImageView.center.y - _labelAboveThumb.frame.size.height * 0.6f);
    
}


- (void)updateTrackHighlight
{
    // Create a mask layer and the frame to determine what will be visible in the view.
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGFloat thumbMidXInHighlightTrack = CGRectGetMidX([self convertRect:_thumbImageView.frame toView:_trackImageViewNormal]);
    CGRect maskRect = CGRectMake(0, 0, thumbMidXInHighlightTrack, _trackImageViewNormal.frame.size.height);
    
    // Create a path and add the rectangle in it.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, nil, maskRect);
    
    // Set the path to the mask layer.
    [maskLayer setPath:path];
    
    // Release the path since it's not covered by ARC.
    CGPathRelease(path);
    
    // Set the mask of the view.
    _trackImageViewNormal.layer.mask = maskLayer;
}


- (void)ParserXML:(GDataXMLElement *)elementy
{
    self.controlId = [[elementy attributeForName:XML_ID_ATTR] stringValue] ;//获取节点的Id属性
    self.orientation = [[[elementy attributeForName:XML_ORIENTATION_ATTR] stringValue] intValue];
    self.zIndex = [[[elementy attributeForName:XML_Z_INDEX_ATTR] stringValue] intValue];
    self.nVisible = [[[elementy attributeForName:XML_VISIBLE_ATTR] stringValue] intValue];
    self.nEnable = [[[elementy attributeForName:XML_ENABLE_ATTR] stringValue] intValue];
    self.nCurValue = [[[elementy attributeForName:XML_VALUE_ATTR] stringValue] intValue];
    
    self.silder_markHeight=[[[elementy attributeForName:XML_SLIDER_MARKHEIGHT] stringValue] intValue];
    self.silder_markWidth=[[[elementy attributeForName:XML_SLIDER_MARKWIDTH] stringValue] intValue];
    self.silder_mainHeight=[[[elementy attributeForName:XML_SLIDER_MAINHEIGHT] stringValue] intValue];
    self.silder_mainWidth=[[[elementy attributeForName:XML_SLIDER_MAINWIDTH] stringValue] intValue];
    
    self.silder_mainBackgroundImage = [[elementy attributeForName:XML_SLIDER_MAINBACKGROUNDIMAGE] stringValue];
    self.silder_mainBackgroundColor =[[elementy attributeForName:XML_SLIDER_MAINBACKGROUNDCOLOR] stringValue];
    
    self.silder_markBackgroundColor=[[elementy attributeForName:XML_SLIDER_MARKBACKGROUNDCOLOR] stringValue];
    self.silder_markBackgroundImage=[[elementy attributeForName:XML_SLIDER_MARKBACKGROUNDIMAGE] stringValue];
    
    
    if ([self.silder_mainBackgroundColor length]==0) {
        
        self.silder_mainBackgroundColor=DEFAULT_MAINBACKGROUND_COLOR;
    }
    
    if ([self.silder_markBackgroundColor length]==0) {
        
        self.silder_markBackgroundColor=DEFAULT_MAINBACKGROUND_COLOR;
        
    }
    
    
    //设置坐标
    NSString* geometry = [[elementy attributeForName:XML_GEOMETRY_ATTR] stringValue];//获取节点的geometry属性
    
    NSLog(@"坐标geometry________%@",geometry);
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
        if(parserXMLService){
            
            f[0] = f[0] * parserXMLService.hRatio;
            f[1] = f[1] * parserXMLService.cRatio;
            f[2] = f[2] * parserXMLService.hRatio;
            f[3] = f[3] * parserXMLService.cRatio;
            
            self.silder_markWidth  = self.silder_markWidth  * parserXMLService.hRatio;
            self.silder_markHeight = self.silder_markHeight * parserXMLService.cRatio;
            self.silder_mainWidth  = self.silder_mainWidth  * parserXMLService.hRatio;
            self.silder_mainHeight = self.silder_mainHeight * parserXMLService.cRatio;
        }
        
        
        
        //根据滑动条方向改变坐标
        if(self.orientation == 1)
        {
            
            CGFloat fX = (2*f[0] + f[2] - f[3])/2;
            CGFloat fY = (2*f[1] + f[3] - f[2])/2;
            
            [self setFrame:CGRectMake(fX,fY,f[3],f[2])];
            //旋转
            [self setTransform:CGAffineTransformMakeRotation(trangle(-90))];
            
            
        }else {
            
            [self setFrame:CGRectMake(f[0], f[1], f[2], f[3])];
            
        }
        
        //MainImage
        SocketServices *socketServer = [SocketServices sharedSocketServices];
        if(nil == socketServer)
            return;
        
        NSString *imageSourcePath = [socketServer.xmlSourcePath
                                     stringByAppendingPathComponent:IMAGE_RESOURCE];
        
        //mainImg
        self.silder_mainBackgroundImage = [imageSourcePath stringByAppendingPathComponent:self.silder_mainBackgroundImage];
        
        NSData* backgroundImageData = [NSData dataWithContentsOfFile:self.silder_mainBackgroundImage];
        
        UIImage* mainimg = [UIImage imageWithData:backgroundImageData];
        
        // the track background images
        _trackImageViewNormal=[[UIImageView alloc] initWithImage:mainimg];
        
        if (_trackImageViewNormal.image==nil) {
            
            [_trackImageViewNormal setBackgroundColor:[ParserXMLService colorWithHexString:self.silder_mainBackgroundColor]];
            
        }
        [_trackImageViewNormal setBackgroundColor:[ParserXMLService colorWithHexString:self.silder_mainBackgroundColor]];
        //MarkImg
        
        self.silder_markBackgroundImage = [imageSourcePath stringByAppendingPathComponent:self.silder_markBackgroundImage];
        
        NSData* backgroundImageDatamark = [NSData dataWithContentsOfFile:self.silder_markBackgroundImage];
        
        UIImage* markimg = [UIImage imageWithData:backgroundImageDatamark];
        
        // thumb knob
        _thumbImageView = [[UIImageView alloc] initWithImage:markimg];
        
        if (_thumbImageView.image==nil) {
            
            [_thumbImageView setBackgroundColor:[UIColor blueColor]];
        }
        [_thumbImageView setBackgroundColor:[ParserXMLService colorWithHexString:self.silder_markBackgroundColor]];
        
        
        [self addSubview:_trackImageViewNormal];
        [_trackImageViewNormal addSubview:_thumbImageView];
    }
    
    //可用和可见属性
    if(self.nEnable == 0)
        [self setEnabled:NO];
    if(self.nVisible == 0)
        [self setHidden:YES];
    //设置标签
    [self setTag:[self.controlId intValue]];
    
}


//值修改发送事件
-(void)onValueChangedEvent
{
    
    [self setNCurValue:self.value];
    
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
        
        [socketService sendControlEvent:self.controlId withEventType:EVENT_SLIDER_VALUE_CHANGED withData:data andDataLen:4];
    }
    
}


#pragma mark - Accessor Overriding
// use diffrent track background images accordingly
- (void)setStepped:(BOOL)stepped
{
    _stepped = stepped;
    NSString *trackImageNormal;
    NSString *trackImageHighlighted;
    
    if (_stepped) {
        
        trackImageNormal = _silder_mainBackgroundImage;
        trackImageHighlighted=_silder_mainBackgroundImage;
    }else{
        trackImageNormal = _silder_mainBackgroundImage;
        trackImageHighlighted=_silder_mainBackgroundImage;
    }
    _trackImageViewNormal.image = [UIImage imageNamed:trackImageNormal];
    _trackImageViewHighlighted.image = [UIImage imageNamed:trackImageHighlighted];
    
}

- (void)setValue:(float)value
{
    //    if (value < _minimumValue || value > _maximumValue) {
    //        return;
    //    }
    //
    //    NSLog(@"_minimumValue___%f",_minimumValue);
    //    _value = value;
    //
    //    _thumbImageView.center = CGPointMake([self xForValue:value], _thumbImageView.center.y);
    //
    //    [self setNeedsDisplay];
}

#pragma mark - Helpers
- (void)commonInit
{
    
    _value = 0.f;
    _minimumValue = 0.f;
    _maximumValue = 100.f;
    _continuous = YES;
    //初始化时no
    _thumbOn = NO;
    
    //关掉步进功能
    _stepped = NO;
    _decimalPlaces = 0;
    
    
    
    self.backgroundColor = [UIColor clearColor];
    
    // value labels
    _labelOnThumb = [[UILabel alloc] init];
    _labelOnThumb.backgroundColor = [UIColor clearColor];
    _labelOnThumb.textAlignment = NSTextAlignmentCenter;
    _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
    _labelOnThumb.textColor = [UIColor redColor];
    [self addSubview:_labelOnThumb];
    
    _labelAboveThumb = [[UILabel alloc] init];
    _labelAboveThumb.backgroundColor = [UIColor clearColor];
    _labelAboveThumb.textAlignment = NSTextAlignmentCenter;
    _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
    _labelAboveThumb.textColor = [UIColor colorWithRed:232.f/255.f green:151.f/255.f blue:79.f/255.f alpha:1.f];
    [self addSubview:_labelAboveThumb];
    
    
    _labelAboveThumb.hidden=YES;
    _labelOnThumb.hidden=YES;
}


//滑动的值
- (float)xForValue:(float)value
{
    
    if (self.orientation==1) {
        
        return _trackImageViewNormal.frame.size.width * (value - _minimumValue) / (_maximumValue - _minimumValue);
        
        
    }
    
    return _trackImageViewNormal.frame.size.width * (value - _minimumValue) / (_maximumValue - _minimumValue);
    
}


- (float)valueForX:(float)x
{
    //根据滑动条方向改变坐标
    if(self.orientation == 1)
    {
        
        return _minimumValue + x / self.frame.size.height * (_maximumValue - _minimumValue);
        
    }
    return _minimumValue + x / self.frame.size.width * (_maximumValue - _minimumValue);
}

- (float)stepMarkerXCloseToX:(float)x
{
    
    float xPercent = MIN(MAX(x / _trackImageViewNormal.frame.size.width, 0), 1);
    float stepPercent = 0.f / 100.f;
    float midStepPercent = stepPercent / 2.f;
    int stepIndex = 0;
    while (xPercent > midStepPercent) {
        stepIndex++;
        midStepPercent += stepPercent;
    }
    
    return stepPercent * (float)stepIndex * _trackImageViewNormal.frame.size.width;
}
- (NSString *)valueStringFormat
{
    return [NSString stringWithFormat:@"%%.%df", _decimalPlaces];
}

#pragma mark UIControl Method

//  UIControl中处理触摸方法：

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    CGPoint touchPoint = [touch locationInView:_trackImageViewNormal];
    
    if (CGRectContainsPoint(_thumbImageView.frame, touchPoint)) {
        
        _thumbOn=YES;
        
    }else{
        
        _thumbOn=NO;
    }
    
    return YES;
}


-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    if(!_thumbOn) return YES;
    
    CGPoint touchPoint = [touch locationInView:_trackImageViewNormal];
    
    if (self.orientation==1) {
        
        _thumbImageView.center = CGPointMake( MIN( MAX( self.silder_markHeight/2, touchPoint.x), self.silder_mainHeight - self.silder_markHeight/2), _thumbImageView.center.y);
        
    }else{
        
        
        ///0000
        _thumbImageView.center = CGPointMake( MIN( MAX( (self.silder_markWidth)/2, touchPoint.x),self.silder_mainWidth- self.silder_markWidth/2), _thumbImageView.center.y);
        
        //_thumbImageView.center = CGPointMake(self.silder_markWidth/2, CGRectGetMidY(_trackImageViewNormal.frame));
        
    }
    
    
    
    if (_continuous && !_stepped) {
        
        _value = [self valueForX:self.center.x];
        
        _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
        _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
        
        //添加事件
        [self sendAction:@selector(onValueChangedEvent) to:nil forEvent:event];
        
    }
    
    [self setNeedsDisplay];
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    if (_thumbOn) {
        if (_stepped) {
            
            _thumbImageView.center = CGPointMake( [self stepMarkerXCloseToX:[touch locationInView:_trackImageViewNormal].x], _thumbImageView.center.y);
            
            [self setNeedsDisplay];
        }
        
        _value = [self valueForX:_thumbImageView.center.x];
        _labelOnThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
        _labelAboveThumb.text = [NSString stringWithFormat:[self valueStringFormat], _value];
        [self sendAction:@selector(onValueChangedEvent) to:nil forEvent:event];
    }
    _thumbOn = NO;
}


@end
