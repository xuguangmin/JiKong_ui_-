//
//  FileDownloadViewController.m
//  PhilisenseProject
//
//  Created by weihuachao on 13-1-9.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "FileDownloadViewController.h"
#import "SocketServices.h"
#import "global.h"
#import "Utilities.h"

@interface FileDownloadViewController ()

@end

@implementation FileDownloadViewController

@synthesize lblDownloadPercent = _lblDownloadPercent,progressView = _progressView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reponseFileDownloadNotifiction:) 
                                                 name:REQEST_NOTIFICATION_FILE_DOWNLOAD object:nil];
    
    UIImage* loginImage=[UIImage imageNamed:@"loadproc.png"];
    UIImageView *loginImageView = [[UIImageView alloc] initWithImage:loginImage];
    [self.view addSubview:loginImageView];
    [loginImageView release];
    
    self.progressView =[[[THProgressView alloc] initWithFrame:CGRectMake(230.0f, 670.0f, 650.0f, 15.0f)]autorelease];
    self.progressView.backgroundColor=[UIColor clearColor];
    self.progressView.borderTintColor=[UIColor whiteColor];
    self.progressView.progressTintColor=[UIColor blueColor];
    
    self.lblDownloadPercent=[[[UILabel alloc] init]autorelease];
    [self.lblDownloadPercent setFrame:CGRectMake(920,640,75,65)];
    self.lblDownloadPercent.textColor=[UIColor whiteColor];
    self.lblDownloadPercent.backgroundColor=[UIColor clearColor];
    self.lblDownloadPercent.text=@"0%";
    
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.lblDownloadPercent];
    
}

- (void)viewDidUnload
{
    self.progressView = nil;
    self.lblDownloadPercent = nil;
    
    [super viewDidUnload];
    [self.view hideActivityViewAtCenter];
    // Release any retained subviews of the main view.
     [[NSNotificationCenter defaultCenter] removeObserver:self name:REQEST_NOTIFICATION_FILE_DOWNLOAD object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

//响应文件传输
-(void)reponseFileDownloadNotifiction:(id)sender
{
    id object = [sender object];
    SocketServices *sockerServer = (SocketServices*)object;
    if(sockerServer){
        unsigned int receivedLen = sockerServer.unReceivedFileLen;
        unsigned int fileLen = sockerServer.unTotalFileLen;
    
        float labelvalue =(float)((receivedLen*100)/fileLen);
        int Intvalue=(int)labelvalue;

        self.lblDownloadPercent.text=[NSString stringWithFormat:@"%d%%",Intvalue];
        //下载进度条
        float value=(float)(receivedLen)/fileLen;
        self.progressView.progress =(value+0.01f);
    
        if(receivedLen == fileLen)
        {
            [self.view showActivityViewAtCenter];
        }
    }
}

-(void)dealloc{
    [_lblDownloadPercent release];
    [_progressView release];
    
    [super dealloc];
}
@end
