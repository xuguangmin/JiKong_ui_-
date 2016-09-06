//
//  PHSlider.h
//  飞利信集控
//
//  Created by flx on 14-6-9.
//
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;
@interface PHSlider : UIControl{
    
    BOOL _thumbOn;                              // track the current touch state of the slider
    UIImageView *_thumbImageView;               // the slide knob
    UIImageView *_trackImageViewNormal;         // slider track image in normal state
    UIImageView *_trackImageViewHighlighted;    // slider track image in highlighted state
    CGRect _rrr;
    //
}

@property (assign, nonatomic) int orientation; //方向,0标示水平,1表示垂直

/**
 same properties by referring UISlider
 */
@property(nonatomic) float value;                           // default 0.0. this value will be pinned to min/max
@property(nonatomic) float minimumValue;                    // default 0.0. the current value may change if outside new min value
@property(nonatomic) float maximumValue;                    // default 1.0. the current value may change if outside new max value
@property(nonatomic, getter=isContinuous) BOOL continuous;   // if set, value change events are generated any time the value changes due to dragging. default = YES


/**
 Use these properties to customize UILabel font and color
 */
@property(nonatomic,assign) UILabel *labelOnThumb;                 // overlayed above the thumb knob, moves along with the thumb You may customize its `font`, `textColor` and other properties.
@property(nonatomic,assign) UILabel *labelAboveThumb;              // displayed on top fo the thumb, moves along with the thumb You may customize its `font`, `textColor` and other properties.
@property(nonatomic) int decimalPlaces;                     // determin how many decimal places are displayed in the value labels

@property(nonatomic, getter = isStepped) BOOL stepped;      // if set, the slider is segmented with 6 values, and thumb only stays on these values. default = NO. (Note: the stepped slider is not fully implemented, I'm considering adding a NSArray steppedValues property in next release)


-(void)ParserXML:(GDataXMLElement*)elementy;

@property (strong, nonatomic) NSString* silder_mainBackgroundColor;
@property (strong, nonatomic) NSString* silder_mainBackgroundImage;

//markColor
@property (strong, nonatomic) NSString* silder_markBackgroundColor;
@property (strong, nonatomic) NSString* silder_markBackgroundImage;


@property (strong, nonatomic) NSString *controlId;


//silder_markHeight
@property (assign, nonatomic) int silder_markHeight;
//silder_markWidth
@property (assign, nonatomic) int silder_markWidth;

//silder_mainHeight
@property (assign, nonatomic) int silder_mainHeight;
//silder_mainWidth
@property (assign, nonatomic) int silder_mainWidth;



@property (assign, nonatomic) int zIndex;
@property (assign, nonatomic) int nVisible;
@property (assign, nonatomic) int nEnable;
@property (assign, nonatomic) int nCurValue;

@end
