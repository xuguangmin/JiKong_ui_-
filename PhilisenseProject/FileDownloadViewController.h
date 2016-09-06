//
//  FileDownloadViewController.h
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THProgressView.h"
@interface FileDownloadViewController : UIViewController
{
    THProgressView* _progressView;//进度条
    UILabel* _lblDownloadPercent;//显示下载的进度
}

@property(nonatomic,retain)UILabel* lblDownloadPercent;
@property(nonatomic,retain)THProgressView* progressView;


-(void)reponseFileDownloadNotifiction:(id)sender;
@end
