//
//  THProgressView.h
//  飞利信集控
//
//  Created by flx on 14-8-6.
//
//

#import <UIKit/UIKit.h>

@interface THProgressView : UIView

@property (nonatomic, strong) UIColor* progressTintColor;
@property (nonatomic, strong) UIColor* borderTintColor;
@property (nonatomic) CGFloat progress;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end