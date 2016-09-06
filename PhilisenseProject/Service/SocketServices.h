//
//  SocketServices.h
//  ZhongCaiRenMai
//
//  Created by huachang li on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#ifndef nTagLen
#define nTagLen 4096    //
#endif

#ifndef nHeaderLen
#define nHeaderLen 7
#endif
#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface SocketServices : NSObject<AsyncSocketDelegate,UIAlertViewDelegate>{
    
    FILE *m_recvFP;                     //接收文件句柄
    
    unsigned char *m_cTempBuff;         //临时缓存
    int m_nTempBuffLen;                 //临时缓存实际数据长度
    int m_nTempBuffSize;                //临时缓存大小
    
    int m_nCurPackageTotalLen;          //当前数据包总长度
    
    AsyncSocket *asyncSocket;
    
    BOOL isConnet;                      //标记是否连接服务器成功
    BOOL cannet;                        //标记是否有网络连接
    NSString *filepath;
    unsigned int _unTotalFileLen;      //文件总长度
    unsigned int _unReceivedFileLen;   //已接收文件长度
    
    NSUserDefaults* _userDefaults;
    NSString * _documentsPath;
    NSString * _xmlSourcePath;
    NSString * _zipSourcePath;
    NSFileManager *_fileManager;
    
    NSTimer *_heartBeatTimer;
}

@property(nonatomic,retain) NSString* filepath;
@property(nonatomic,retain) NSUserDefaults* userDefaults;
@property(nonatomic,retain) NSTimer* heartBeatTimer;
@property(nonatomic,retain) AsyncSocket *asyncSocket;
@property(assign)unsigned int unTotalFileLen;
@property(assign)unsigned int unReceivedFileLen;

@property (nonatomic,strong) NSString * documentsPath;
@property (nonatomic,strong) NSString * xmlSourcePath;
@property (nonatomic,strong) NSString * zipSourcePath;
@property (nonatomic,strong) NSFileManager *fileManager;

+(SocketServices *)sharedSocketServices;

-(void)login:(NSString *)serverIp withServerPort:(NSString *)serverPort;
-(void)onHeartBeat;

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;

-(int) dealWithData :(char *) apBuff withLen:(int) anLen;
-(void) dealWithCompletePackage:(unsigned char*)data withLen:(int) nLen;

-(void)dealwithFileVersionInfoPackage:(unsigned char*)data withLen:(int) nLen;
-(void)dealFilecrequestDataForServer:(unsigned char*)data withLen:(int)dataLength;
-(void)dealFile:(unsigned char *)data withLen:(int)nLen;
-(void)dealWithFileDoneCompletePackage;

-(void)sendLogin;

-(void)sendControlEvent:(NSString*)controlId withEventType:(int)event;

-(void)sendControlEvent:(NSString*)controlId withEventType:(int)event withData:(Byte*)data andDataLen:(int)len;

-(void)sendPacketWith:(Byte)operationCode WithCommand:(Byte)operationCodeEx WithData:
(Byte*)data dataLength:(int)length;


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
