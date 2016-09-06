//
//  UTXConstants.h
//  UTX
//
//  Created by jianjun zheng on 11-9-28.
//  Copyright 2011年 SouFun. All rights reserved.
//



#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "AppDelegate.h"

#include <unistd.h>


#define MERCATOR_OFFSET 268435456 //(total pixels at zoom level 20) / 2
#define MERCATOR_RADIUS 85445659.44705395 //ERCATOR_OFFSET / pi
#define SF_COLOR(RED, GREEN, BLUE, ALPHA)	[UIColor colorWithRed:RED green:GREEN blue:BLUE alpha:ALPHA]
#define SF_BARBUTTON_TITLE(TITLE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SF_BARBUTTON_IMAGE(IMAGE, SELECTOR) 	[[[UIBarButtonItem alloc] initWithImage:IMAGE style:UIBarButtonItemStylePlain target:self action:SELECTOR] autorelease]
#define SF_BARBUTTON_CUSTOMVIEW(customView)		[[UIBarButtonItem alloc] initWithCustomView:customView]
#define SF_BARBUTTON_ITEM(ITEM, SELECTOR) [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:ITEM target:self action:SELECTOR] autorelease]
#define SF_BASIC_COLOR SF_COLOR(0.000000,0.533333,0.905882,1)

#define NSSTRING_CLASS @"NSString"
#define NSDATA_CLASS @"NSData"
#define NSDICTIONARY_CLASS @"NSDictionary"
#define NSARRAY_CLASS @"NSArray"

@interface UtilityHelper : NSObject {
	
}
+ (void)deleteImage;
+ (NSString *)applicationDocumentsDirectory;
+ (AppDelegate *)applicationDelegate;
+(void)hideTabBar;
+(void)showTabBar;

+ (UILabel *)addLabelWithRect:(CGRect)rect text:(NSString *)text tag:(NSInteger)tag fontSize:(float)fonSize color:(UIColor *)color alignment:(UITextAlignment)alignment onView:(UIView *)view;


+ (NSString *) md5:(NSString *)str;
+ (NSData *)Convert2Utf8:(NSData *)data;


+ (NSString *)getComData:(NSString *)addTime;
+ (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage size:(CGSize)imageSize;
+ (UIImage *)makeThumbnailFromImage:(UIImage *)srcImage scale:(double)imageScale;

+(BOOL)isEmpty:(NSString *) string;

//+ (NSString *)getPicUrlByWidthAndHeight:(NSString *)url width:(NSString *)width height:(NSString *)height ;

+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

/**
 需要特别编码
 */
+ (NSString *)encodeToPercentEscapeString:(NSString *) input;  
+ (NSString *)EncodeGB2312Str:(NSString *)encodeStr;//gbk
+ (NSString *)decodeFromPercentEscapeString:(NSString *) input;
//+ (BOOL)isExistenceNetwork;
+ (NSString *)getHostServerPath;
+ (NSString *)getBusinessInterfacePath:(NSString *)businessName;
+ (NSString *)getInterfaceAndParamersUrl:(NSString *)businessName paramers:(NSDictionary *)dicParmers;
+ (NSString *)getInterfaceAndParamersUrlForPost:(NSString *)businessName paramers:(NSDictionary *)dicParmers;


//计算时间 例如：刚刚、几秒钟前、几分钟前
+ (NSString *)calculateTime:(NSString *)dateString;
+ (NSString *)calculateTimeWithhour:(NSString *)dateString ;


+(NSString *)getChinaDate:(NSString *) dateString;


+(UIButton *)getSouFunBasicBarButton:(NSString*)buttonTiltle;
+(UIButton *)getSouFunBasicBarButton:(NSString*)buttonTiltle withImageName:(NSString *)imageName;

    
@end

@interface UIView (UIViewUtils) 

- (void)showActivityViewAtCenter;
- (void)hideActivityViewAtCenter;
- (void)createActivityViewAtCenter:(UIActivityIndicatorViewStyle)style;
- (UIActivityIndicatorView*)getActivityViewAtCenter;

@end