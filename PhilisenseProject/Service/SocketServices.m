//
//  SocketServices.m
//  ZhongCaiRenMai
//
//  Created by huachang li on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <stdio.h>
#import <string.h>
#import "AppDelegate.h"
#import "SocketServices.h"
#import "ParserXmlService.h"
#import "LoginViewController.h"
#import "RootViewController.h"
#import "UserBasicInfo.h"
#import "global.h"
#import "ZipArchive.h"
#import "FileDownloadViewController.h"
#import "Reachability.h"
#import "PageViewController.h"
#import "PHSlider.h"
#import "PHProgress.h"
#import "PHButton.h"
#import "CheckBox.h"

static SocketServices * _sharedSocketServices = nil;

@implementation SocketServices

@synthesize asyncSocket,filepath;
@synthesize userDefaults = _userDefaults;

@synthesize unTotalFileLen = _unTotalFileLen,unReceivedFileLen = _unReceivedFileLen;
@synthesize documentsPath = _documentsPath;
@synthesize zipSourcePath = _zipSourcePath;
@synthesize xmlSourcePath = _xmlSourcePath;

@synthesize fileManager = _fileManager;
@synthesize heartBeatTimer = _heartBeatTimer;

-(id)init{
    self=[super init];
    if (self) {
        m_cTempBuff  =  ( unsigned char *) malloc(nTagLen);   //
        m_nCurPackageTotalLen = 0;                   //
        m_nTempBuffSize = nTagLen;                   //
        m_nTempBuffLen = 0;
        m_recvFP = NULL;
        isConnet = NO;
        cannet = NO;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                     NSUserDomainMask, YES);
        self.documentsPath = [documentPaths objectAtIndex:0];
        NSFileManager* manager = [[NSFileManager alloc] init];
        self.fileManager = manager;
        [manager release];
        
        //指定存放解压后xml文件路径
        self.xmlSourcePath = [self.documentsPath stringByAppendingPathComponent:XML_RESOURCE];
        BOOL exists = [self.fileManager fileExistsAtPath:self.xmlSourcePath];
        if(!exists){
            NSError *err = nil;
            [self.fileManager createDirectoryAtPath:self.xmlSourcePath withIntermediateDirectories:NO attributes:nil error:&err];
        }
        //指定存放解压后xml文件路径
        self.zipSourcePath = [self.documentsPath stringByAppendingPathComponent:ZIP_RESOURCE];
        exists = [self.fileManager fileExistsAtPath:self.zipSourcePath];
        if(!exists){
            NSError *err = nil;
            [self.fileManager createDirectoryAtPath:self.zipSourcePath withIntermediateDirectories:NO attributes:nil error:&err];
        }
        
        //心跳
        self.heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(onHeartBeat) userInfo:nil repeats:YES];
    }
    return self;
    
}

+(SocketServices *)sharedSocketServices
{
    @synchronized([SocketServices class])
    {
        if (!_sharedSocketServices)
        {
            _sharedSocketServices = [[SocketServices alloc] init];
        }
        
        return _sharedSocketServices;
    }
    
    return nil;
}

-(void)dealloc{
    
    [asyncSocket release];
    [filepath release];
    [_userDefaults synchronize];
    [_userDefaults release];
    [_documentsPath release];
    [_xmlSourcePath release];
    [_zipSourcePath release];
    [_fileManager release];
    [_heartBeatTimer release];
    
    free(m_cTempBuff);
    if (m_recvFP != nil) {
        fclose(m_recvFP);
    }
    [super dealloc];
    
}
//发送心跳包
-(void)onHeartBeat
{
    if(isConnet)
        [self sendPacketWith:0x00 WithCommand:0x00 WithData:nil dataLength:0];
}
-(int) dealWithData :(char *) apBuff withLen:(int) anLen{
    int nLen = 0;
    while(nLen < anLen)
    {
        //检查是否有临时数据
        if(m_nTempBuffLen < 7)
        {
            if(m_nTempBuffLen + (anLen - nLen)< 7) //还不够7个字节
            {
                memcpy(m_cTempBuff + m_nTempBuffLen,apBuff + nLen,anLen - nLen);
                m_nTempBuffLen += anLen - nLen;
                break;
            }else
            {
                memcpy(m_cTempBuff + m_nTempBuffLen,apBuff + nLen,7 - m_nTempBuffLen);
                nLen += 7 - m_nTempBuffLen;
                m_nTempBuffLen += 7 - m_nTempBuffLen;
            }
        }else
        {
            if(m_nTempBuffLen == 7)
            {
                //提取数据包长度
                m_nCurPackageTotalLen = m_cTempBuff[3]<<24|m_cTempBuff[4]<<16|m_cTempBuff[5]<<8|m_cTempBuff[6];
                if(m_nCurPackageTotalLen > m_nTempBuffSize - 9)//新来数据总长度已经超出当前临时缓冲区，初始值为1024
                {
                    char tempBuff[7];
                    memcpy(tempBuff,m_cTempBuff,7);
                    free(m_cTempBuff);
                    m_cTempBuff  =  ( unsigned char *) malloc(m_nCurPackageTotalLen + 9);
                    memcpy(m_cTempBuff,tempBuff,7);
                    m_nTempBuffSize = m_nCurPackageTotalLen + 9;
                }
            }
            if(anLen - nLen < m_nCurPackageTotalLen + 9 - m_nTempBuffLen)
            {
                memcpy(m_cTempBuff + m_nTempBuffLen,apBuff + nLen,anLen - nLen);
                m_nTempBuffLen += anLen - nLen;
                break;
            }else
            {
                memcpy(m_cTempBuff + m_nTempBuffLen,apBuff + nLen,m_nCurPackageTotalLen + 9 - m_nTempBuffLen);
                nLen += m_nCurPackageTotalLen + 9 - m_nTempBuffLen;
                
                [self dealWithCompletePackage:m_cTempBuff withLen:m_nCurPackageTotalLen + 9];
                m_nCurPackageTotalLen = 0;
                m_nTempBuffLen = 0;
            }
        }
    }
    return 0;
}
-(void) dealWithCompletePackage:(unsigned char*)data withLen:(int) nLen{
    if(data == NULL || nLen <=0 )
        return;
    //校验
    int nCrc=0;
    for (int i=0; i<nLen-2; i++) {
        nCrc+=data[i];
    }
    unsigned char commandF= nCrc>>8 & 0xFF;//得到校验码
    unsigned char commandS= nCrc & 0xFF;
    if (commandF==data[nLen-2]&&commandS==data[nLen-1]) {
        if(data[0] == 0x7e){
            Byte buff[] = {0x01};
            unsigned int nCmd = data[1];   //指令
            unsigned int nExCmd = data[2]; //扩展指令
            unsigned int nData=data[7];
            switch (nCmd) {
                case 0x12:{//返回资源文件信息
                    switch (nExCmd) {
                        case 0x04://文件版本信息
                            switch (nData) {
                                case 0x01:
                                    [self dealwithFileVersionInfoPackage:data withLen:nLen];
                                    break;
                                case 0xFF:
                                    NSLog(@"Request fileVersion failed.");//?????这些地方也要处理
                                    break;
                            }break;
                        case 0x01://下载
                            switch (nData) {
                                case 0x01:
                                    [self dealFilecrequestDataForServer:data withLen:nLen];
                                    break;
                                case 0xFF:
                                    NSLog(@"Request download file failed.");//?????这些地方也要处理
                                    break;
                            }break;
                        case 0x02:
                            switch (nData) {//服务器端响应
                                case 0x01:
                                    [self dealFile:data withLen:nLen];
                                    break;
                                case 0xFF:
                                    NSLog(@"Server respond failed.");//?????这些地方也要处理
                                    break;
                                default:
                                    break;
                            }break;
                        case 0x03:
                            switch (nData) {//服务端传送文件数据完毕
                                case 0xFE:
                                    [self dealWithFileDoneCompletePackage];
                                    break;
                                case 0xFF:
                                    NSLog(@"recv file failed.");//?????这些地方也要处理
                                    break;
                            }break;
                        case 0x05://通知触屏更新文件
                            [self sendPacketWith:0x12 WithCommand:0x04 WithData:buff dataLength:1];
                            break;
                    }break;
                }break;
                case 0x39:  //服务器返回控件事件处理
                {
                    switch (nExCmd) {
                            //                            char buff_Id[4];//
                            //                            memcpy(buff_Id, data+7, 4);//获取控件ID
                            //                            NSString* Id=[NSString stringWithCString:buff_Id encoding:NSUTF8StringEncoding];
                            //                            NSLog(@"id=======================%@",Id);
                            //                            char buff_Value[4];
                            //                            memcpy(buff_Value, data+11, 4);//获取控件属性码
                            //                            NSString* attr=[NSString stringWithCString:buff_Value encoding:NSUTF8StringEncoding];
                            //                            NSLog(@"attr========%@",attr);
                            
                        case 0x11:
                            NSLog(@"设置控件的属性.");
                            [self dealwithserverevent:data withLen:nLen];
                            break;
                        case 0x12:
                            NSLog(@"获取控件的属性.");
                            break;
                        default:
                            break;
                    }
                    
                }break;
                case 0x00://心跳检测
                    //m_count--;
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark - AsyncSocket CALLBACKS
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    isConnet = YES;
    
    //设置登录状态 为已登录
    UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
    if ([userInfo.logInStatus isEqualToString:@"0"]) {
        userInfo.logInStatus = @"1";
    }
    [asyncSocket readDataWithTimeout:-1 tag:1];
    //将登录窗口隐藏
    [self performSelector:@selector(sendLogin) withObject:nil afterDelay:1];
    
    [self.heartBeatTimer fire];//手动启动定时器
    //通知登录状态
    [[NSNotificationCenter defaultCenter] postNotificationName:REQEST_NOTIFICATION_TYPE_LOGIN object:self];
}

-(void)sendLogin{
    
    Byte buff[] = {0x01};//表示ios界面资源文件(压缩包)
    //客户端请求连接
    [self sendPacketWith:0x10 WithCommand:0x02 WithData:nil dataLength:0];
    //请求文件版本信息
    [self sendPacketWith:0x12 WithCommand:0x04 WithData:buff dataLength:1];
}
//接收数据
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self dealWithData:(char *)[data bytes] withLen:data.length];
    [asyncSocket readDataWithTimeout:-1 tag:1];
}


//连接断开
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    isConnet = NO;
    if([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus]!= NotReachable ||[[Reachability reachabilityForInternetConnection] currentReachabilityStatus]!= NotReachable)
    {
        cannet = YES;
    }
    else{
        cannet = NO;
    }
    NSLog(@"will disconnect:%@", err);
    
    [self.heartBeatTimer invalidate];//手动释放定时器
    
    //设置登录状态 为未登录
    UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
    if ([userInfo.logInStatus isEqualToString:@"1"]) {
        userInfo.logInStatus = @"0";
    }
    
    //
    
    /*
     if (cannet)
     {
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     UINavigationController *navigCon = appDelegate.NavCon;
     if (navigCon.presentedViewController == [LoginViewController sharedloginViewController]) {
     //通知登录状态
     [[NSNotificationCenter defaultCenter] postNotificationName:REQEST_NOTIFICATION_TYPE_LOGIN object:self];
     }
     else{
     //提示用户继续操作
     UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"网络连接失败" message:@"重新尝试连接,还是运行单机版程序?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续尝试",@"运行单机版", nil];
     [alertView show];
     [alertView release];
     }
     
     }
     else{
     //通知登录状态
     [[NSNotificationCenter defaultCenter] postNotificationName:REQEST_NOTIFICATION_TYPE_LOGIN object:self];
     
     UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"无连接" message:@"无线网络无连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
     [alertview show];
     [alertview release];
     }
     */
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(buttonIndex == 1){   //继续尝试连接
        UserBasicInfo * userInfo = [UserBasicInfo sharedUserBasicInfo];
        if (userInfo) {
            [self login:userInfo.serverIP withServerPort:userInfo.serverPort];
        }
        
    }else if(buttonIndex == 2){ //运行单机版
        UserBasicInfo * userInfo=[UserBasicInfo sharedUserBasicInfo];
        if(userInfo){
            userInfo.runModel = @"0";   //标示为单机运行模式
        }
        [[ParserXMLService sharedParserXMLService] parserXml];
    }else{  //退出应用程序
        
        //        [[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
    }
}

-(void)login:(NSString *)serverIP withServerPort:(NSString *)serverPort{
    
    if (!isConnet) {
        
        AsyncSocket * socket = [[AsyncSocket alloc] initWithDelegate:self];
        
        self.asyncSocket = socket;
        
        
        [socket release];
        
        NSError *err = nil;
        
        if(![asyncSocket connectToHost:serverIP onPort:serverPort.intValue withTimeout:30.00  error:&err])
        {
            NSLog(@"Error: %@", err);
        }
        [asyncSocket readDataWithTimeout:-1 tag:1];
    }
}

/*
 创建一个包，以便发送
 */
-(void)sendPacketWith:(Byte)operationCode WithCommand:(Byte)operationCodeEx WithData:(Byte*)data dataLength:(int)length
{
    if (length >= 0 && isConnet) {
        NSLog(@"send data.");
        unsigned char sendBuffer[9 + length];
        
        sendBuffer[0] = 0x7e;
        sendBuffer[1] = operationCode;
        sendBuffer[2] = operationCodeEx;
        
        sendBuffer[3] = length>>24;
        sendBuffer[4] = length<<8>>24;
        sendBuffer[5] = length<<16>>24;
        sendBuffer[6] = length<<24>>24;
        
        if(length > 0)
            memcpy(sendBuffer + 7, data, length);
        
        int nCrc = 0;;
        for(int i = 0; i<length + 7;i++)
        {
            nCrc += sendBuffer[i];//计算出校验码(数据包头 + 指令码 + 扩展指令 + 数据长度(表示数据长度的四个字节累加和) + 数据(N个实际数据字节的累加和) = 校验)
        }
        
        sendBuffer[7 + length] = ((nCrc<<16)>>24);
        sendBuffer[8 + length] = ((nCrc<<24)>>24);//得到校验码(协议规定的)
        
        NSData * sendData = [NSData dataWithBytes:sendBuffer length:9 + length];
        //线程保护
        @synchronized(self){
            [asyncSocket writeData:sendData withTimeout:-1 tag:0];
            [asyncSocket readDataWithTimeout:-1 tag:0];
        }
    }
}

-(void)dealwithserverevent:(unsigned char*)data withLen:(int) nLen
{
    int len = data[3]<<24|data[4]<<16|data[5]<<8|data[6]; //获取数据长度
    NSLog(@"%d",len);
    int controlID = data[7]<<24|data[8]<<16|data[9]<<8|data[10]; //获取控件ID
    int controlAtr = data[11]<<24|data[12]<<16|data[13]<<8|data[14]; //获取控件属性码即是神马控件
    int atrvalue = data[15]<<24|data[16]<<16|data[17]<<8|data[18]; //获取属性的值
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UINavigationController *navigCon = appDelegate.NavCon;
    PageViewController *curViewController = (PageViewController *)[navigCon presentedViewController];
    if(curViewController)
    {
        [self dealwithEventsinView:curViewController withId:controlID withatr:controlAtr withatrvalue:atrvalue];
    }
}

//文件版本信息处理函数
-(void)dealwithFileVersionInfoPackage:(unsigned char*)data withLen:(int) nLen
{
    if (data) {
        char versionTime[nLen-9];
        memcpy(versionTime,data+8,nLen-10);
        versionTime[nLen-10] = '\0';
        //将char类型转换成NSString类型
        NSString* str = [[NSString alloc] initWithCString:(const char*)versionTime
                                                 encoding:NSUTF8StringEncoding];
        //读取工程版本键的值
        NSString* projectVersion = [self.userDefaults objectForKey:KEY_PROJECT_VERSION];
        
        NSArray* filenames = [self.fileManager subpathsAtPath:self.zipSourcePath];
        if ([projectVersion isEqualToString:str] && filenames) {
            [[ParserXMLService sharedParserXMLService] parserXml];
        }else{
            //把版本时间写到本地文件中去，以便程序退出后下一次启动读取
            [self.userDefaults setObject:str forKey:KEY_PROJECT_VERSION];
            [self.userDefaults synchronize];
            Byte buff[] = {0x01};//ios界面资源文件(压缩包)
            //请求下载文件
            [self sendPacketWith:0x12 WithCommand:0x01 WithData:buff dataLength:1];
        }
        
        
        [str release];
    }
}
-(void)dealFilecrequestDataForServer:(unsigned char*)data withLen:(int)dataLength
{
    int len=data[3]<<24|data[4]<<16|data[5]<<8|data[6];//len为数据长度=文件类型+文件长度+文件名长度
    
    _unTotalFileLen=data[8]<<24|data[9]<<16|data[10]<<8|data[11];//文件长度
    _unReceivedFileLen = 0;
    
    char fileNameBuffer[len-4];
    memset(fileNameBuffer, 0, len-4);//初始化
    memcpy(fileNameBuffer, data+12, len-5);//实际长度len-5
    NSString* fileName=[NSString stringWithCString:fileNameBuffer encoding:NSUTF8StringEncoding];//下载文件名
    NSLog(@"download filename is %@\n\n %d",fileName,len-5);
    
    //清空压缩包文件路径
    [self.fileManager removeItemAtPath:self.zipSourcePath error:NO];
    [self.fileManager createDirectoryAtPath:self.zipSourcePath withIntermediateDirectories:NO
                                 attributes:nil error:nil];
    
    [self.userDefaults setObject:fileName forKey:KEY_ZIP_FILENAME]; //保存zip文件名称
    
    //获取文件路径(filename包含LTX-1200C.zip文件的完整路径)
    self.filepath = [self.zipSourcePath stringByAppendingPathComponent:fileName];
    
    m_recvFP = fopen((char*)[filepath UTF8String], "a+");
    if (m_recvFP) {
        //初始化进度条
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *navigCon = appDelegate.NavCon;
        [navigCon.topViewController dismissViewControllerAnimated:NO completion:^{
        }];
        FileDownloadViewController * fileViewController = [[[FileDownloadViewController alloc]init]autorelease];
        //        [navigCon presentModalViewController:fileViewController animated:NO];
        [navigCon presentViewController:fileViewController animated:NO completion:^{
        }];
        UINavigationController *nav= [[UINavigationController alloc]init];
        [nav release];
        //        [FileDownloadViewController release];
        
        
        [self.heartBeatTimer invalidate];//手动释放定时器
        
        Byte buff[] = {0x01};
        [self sendPacketWith:0x12 WithCommand:0x02 WithData:buff dataLength:1];//c向S请求发送数据
    }else{
        //下载文件失败,重新尝试
    }
    
}
//接收到文件内容
-(void)dealFile:(unsigned char *)data withLen:(int)nLen
{
    if (data) {
        int len=data[3]<<24|data[4]<<16|data[5]<<8|data[6];
        char fileBuffer[len-1];
        memcpy(fileBuffer, data+8, len-1);
        _unReceivedFileLen += len - 1;
        //通知界面文件下载进度
        [[NSNotificationCenter defaultCenter] postNotificationName:REQEST_NOTIFICATION_FILE_DOWNLOAD object:self];
        size_t count=fwrite(fileBuffer, len-1, 1, m_recvFP);
        if (count) {
            Byte buff[]={0xFE,0x01};
            [self sendPacketWith:0x12 WithCommand:0x02 WithData:buff dataLength:2];//写入数据成功，向服务器发送成功指令
        }else{
            Byte buff[]={0xFF,0x01};
            [self sendPacketWith:0x12 WithCommand:0x02 WithData:buff dataLength:2];//写入数据失败，向服务器发送失败指令
        }
    }
}

//下载文件资源完成,解压文件到指定的目录
-(void)dealWithFileDoneCompletePackage
{
    [self.heartBeatTimer fire];//手动启动定时器
    
    fclose(m_recvFP);
    //清空路径
    [self.fileManager removeItemAtPath:self.xmlSourcePath error:NO];
    [self.fileManager createDirectoryAtPath:self.xmlSourcePath withIntermediateDirectories:NO
                                 attributes:nil error:nil];
    //定义压缩文件操作对象
    ZipArchive* zip=[[ZipArchive alloc] init];
    if (zip)
    {
        //打开压缩文件
        BOOL isOpen=[zip UnzipOpenFile:filepath];
        if (isOpen)
        {
            //解压文件到指定的目录
            BOOL isUnzip=[zip UnzipFileTo:self.xmlSourcePath overWrite:YES];
            if (isUnzip)
            {
                NSLog(@"self.xmlSourcePath=============== is %@",self.xmlSourcePath);
                [[ParserXMLService sharedParserXMLService] parserXml];
                
            }
        }
        //关闭压缩文件
        [zip UnzipCloseFile];
    }
    //释放对象
    [zip release];
}

-(void)sendControlEvent:(NSString*)controlId withEventType:(int)event
{
    if(controlId &&  isConnet)
    {
        int nControlId = [controlId intValue];
        Byte buff[8] = {0};//单击事件
        buff[0] = event>>24;
        buff[1] = event>>16;
        buff[2] = event>>8;
        buff[3] = event;
        buff[4] = nControlId>>24;
        buff[5] = nControlId>>16;
        buff[6] = nControlId>>8;
        buff[7] = nControlId;
        //memcpy(buff + 4, idByte, 4);    //添加控件ID
        [self sendPacketWith:0x19 WithCommand:0x03 WithData:buff dataLength:8];
        
    }
}

-(void)sendControlEvent:(NSString*)controlId withEventType:(int)event withData:(Byte*)data andDataLen:(int)len;
{
    if(controlId && event && isConnet)
    {
        int nControlId = [controlId intValue];
        int nTotalLen = 8 + len;
        Byte buff[nTotalLen];
        
        buff[0] = event>>24;            //事件类型
        buff[1] = event>>16;
        buff[2] = event>>8;
        buff[3] = event;
        
        buff[4] = nControlId>>24;
        buff[5] = nControlId>>16;
        buff[6] = nControlId>>8;
        buff[7] = nControlId;           //添加控件ID
        
        if(data)
            memcpy(buff + 8, data, len);    //添加额外数据
        [self sendPacketWith:0x19 WithCommand:0x03 WithData:buff dataLength:nTotalLen];
        
    }
}

//处理服务器端指定控件的事件(显示、隐藏、可用、禁用、值改变、是否被选中)
-(BOOL)dealwithEventsinView:(PageViewController*)controller withId:(int)controlid withatr:(int)atr withatrvalue:(int)atrvalue
{
    BOOL bRet = NO;
    NSString *ctrolatr = nil;
    switch (atr) {
        case 1:
            ctrolatr = XML_ENABLE_ATTR;//是否启用
            break;
        case 2:
            ctrolatr = XML_VISIBLE_ATTR;//是否可见
            break;
        case 3:
            ctrolatr = XML_VALUE_ATTR;//进度条设置值
            break;
        case 4:
            ctrolatr = XML_CHOOSE_ATTR;//是否被选中
            break;
        default:
            break;
    }
    
    if(controller && controlid)
    {
        UIView * controlView = [controller.view viewWithTag:controlid];
        if (controlView) {
            bRet = YES;
            
            if ([ctrolatr isEqualToString:XML_ENABLE_ATTR])
            {
                if ([[controller.controlType objectAtIndex:controlid-1] isEqualToString:CONTROL_TYPE_BUTTON])
                {
                    PHButton *button = (PHButton*)controlView;
                    if (atrvalue==1) {
                        if (button.enabled==NO) {
                            [button setEnabled:YES];
                        }
                    }else{
                        if (button.enabled==YES) {
                            [button setEnabled:NO];
                        }
                    }
                }
                else if ([[controller.controlType objectAtIndex:controlid-1] isEqualToString:CONTROL_TYPE_SLIDER])
                {
                    
                    //Slider
                    PHSlider *slider = (PHSlider*)controlView;
                    
                    
                    if (atrvalue==1) {
                        if (slider.enabled==NO) {
                            [slider setEnabled:YES];
                        }
                    }else{
                        if (slider.enabled==YES) {
                            [slider setEnabled:NO];
                        }
                    }
                }
                
            }
            else if ([ctrolatr isEqualToString:XML_VISIBLE_ATTR])
            {
                if ([[controller.controlType objectAtIndex:controlid-1] isEqualToString:CONTROL_TYPE_BUTTON])
                {
                    PHButton *button = (PHButton*)controlView;
                    if (atrvalue==1) {
                        if (button.hidden==YES) {
                            [button setHidden:NO];
                        }
                    }else{
                        if (button.hidden==NO) {
                            [button setHidden:YES];
                        }
                    }
                }
                else if ([[controller.controlType objectAtIndex:controlid-1] isEqualToString:CONTROL_TYPE_SLIDER])
                {
                    PHSlider *slider = (PHSlider*)controlView;
                    
                    if (atrvalue==1) {
                        if (slider.hidden==YES) {
                            [slider setHidden:NO];
                        }
                    }else{
                        if (slider.hidden==NO) {
                            [slider setHidden:YES];
                        }
                    }
                }
                else if ([[controller.controlType objectAtIndex:controlid-1] isEqualToString:CONTROL_TYPE_Progress])
                {
                    PHProgress *progress=(PHProgress *)controlView;
                    if (atrvalue==1) {
                        if (progress.hidden==YES) {
                            
                            [progress setHidden:NO];
                        }else{
                            
                            if (progress.hidden==NO) {
                                [progress setHidden:YES];
                            }
                        }
                    }
                }
            }
            else if([ctrolatr isEqualToString:XML_VALUE_ATTR])
            {
                PHSlider *slider = (PHSlider*)controlView;
                
                slider.nCurValue=atrvalue;
                slider.value = atrvalue;
            }
            else if ([ctrolatr isEqualToString:XML_VALUE_ATTR])
            {
                PHProgress *progress=(PHProgress*)controlView;
                progress.nCurValue=atrvalue;
                progress.progress=atrvalue;
            }
            else if([ctrolatr isEqualToString:XML_CHOOSE_ATTR])
            {
                CheckBox* checkBox = (CheckBox*)controlView;
                if (atrvalue == 1) {
                    NSLog(@"设置选中");
                    [checkBox setChecked:YES];
                }else{
                    NSLog(@"设置未被选中");
                    [checkBox setChecked:NO];
                }
            }
            else if([ctrolatr isEqualToString:XML_CHOOSE_ATTR])
            {
                RadioBox* radiobox = (RadioBox*)controlView;
                if (atrvalue == 1) {
                    NSLog(@"设置选中");
                    [radiobox setChecked:YES];
                }else{
                    NSLog(@"设置未被选中");
                    [radiobox setChecked:NO];
                }
            }
            
        }
    }
    
    return bRet;
}


@end
