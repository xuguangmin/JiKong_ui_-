//
//  PHLabel.h
//  PhilisenseProject
//
//  Created by flxlq on 13-5-22.
//
//

#import <UIKit/UIKit.h>
@class GDataXMLElement;

@interface PHLabel : UILabel

@property (assign, nonatomic) int zIndex;
@property (assign, nonatomic) int nVisible;
@property (assign, nonatomic) int nEnable;
@property (assign, nonatomic) int nAlignment;   //文本对齐方式
@property (strong, nonatomic) NSString* strBackgroundColor;
@property (strong, nonatomic) NSString* strForgroundColor;

- (void)ParserXML:(GDataXMLElement*)elementy;

@end
