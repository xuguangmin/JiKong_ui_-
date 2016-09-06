//
//  UtilitiesModalAlert.h
//  Neighbor
//
//  Created by 伟 李 on 11-10-13.
//  Copyright 2011年 搜房网. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UtilitiesModalAlert : NSObject
{
	UIAlertView *alertView;
	NSTimer *killTimer;
	BOOL isTimer;
}
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, retain) NSTimer *killTimer;
@property BOOL isTimer;

+ (UtilitiesModalAlert *)sharedInstance;
+ (void)deletesharedInstance;
- (int)showAlertToUser:(NSString *)alertTitle message:(NSString *)alertMessage button:(NSString *)button isTimer:(BOOL)timer;
@end


