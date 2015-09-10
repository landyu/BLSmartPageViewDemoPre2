//
//  TransmitUdp.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/25.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "TransmitUdp.h"
#import "GCDAsyncUdpSocket.h"

NSTimer *udpHeartBeat;
unsigned int CID = 0;
unsigned char SC = 0;
unsigned int connectStatus = 0;
//NSString *ipRouterHost = @"192.168.10.222";
NSString *ipRouterHost = @"192.168.10.193";
NSInteger ipRouterHostPort = 3671;

@interface TransmitUdp()
{
    long tag;
    GCDAsyncUdpSocket *TransmitUdpSocket;
}
@end

@implementation TransmitUdp

+ (TransmitUdp *)sharedInstance
{
    // 1
    static TransmitUdp *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TransmitUdp alloc] init];
    });
    return _sharedInstance;
}

- (void)setupSocket
{
    TransmitUdpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *error = nil;
    
    if (![TransmitUdpSocket bindToPort:57032 error:&error])
    {
        NSLog(@"Error binding: %@", error);
        return;
    }
    if (![TransmitUdpSocket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
        return;
    }
    
    udpHeartBeat = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(udpHeartBeatTimerFired) userInfo:nil repeats:YES];
    [udpHeartBeat setFireDate:[NSDate distantFuture]];//stop heart beat
}

- (void)closeSocket
{
    if (TransmitUdpSocket)
    {
        [TransmitUdpSocket close];
    }
}

- (BOOL) udpSocketIsConnected
{
    if (TransmitUdpSocket == nil)
    {
        return NO;
    }
    
    return [TransmitUdpSocket isConnected];
}


- (BOOL) udpSocketisClosed
{
    if (TransmitUdpSocket == nil)
    {
        return YES;
    }
    
    return [TransmitUdpSocket isClosed];
}


- (void)udpHeartBeatTimerFired
{
    if (connectStatus == 0)
    {
        return;
    }
    
    Byte sendByte[] = {0x06,0x10,0x02,0x07,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
    NSLog(@"SENT (%i): Connection State Request", (int)tag);
    tag++;
    
    
}


- (void)connectDevice
{
    __block Byte sendByte[] = {0x06,0x10,0x02,0x05,0x00,0x1a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x04,0x02,0x00};
    
    __block int connectTimes = 0;
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:26];
    
//        [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
//        NSLog(@"SENT (%i): Connect Times = %d", (int)tag, connectTimes++);
//    tag++;

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        while (connectStatus == 0)
        {
            [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
            NSLog(@"SENT (%i): Connect Times = %d", (int)tag, connectTimes++);
            [NSThread sleepForTimeInterval:5];
            
        }
        tag++;
    });

    
  
   
}

- (void)disconnectDevice
{
    Byte sendByte[] = {0x06,0x10,0x02,0x09,0x00,0x10,CID,0x00,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00};
    
    if (connectStatus == 0)
    {
        return;
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    data = [NSMutableData dataWithBytes:sendByte length:16];
    
    [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
    NSLog(@"SENT (%i): Disconnect CID %u", (int)tag, CID);
    tag++;
    
}

- (void)sendKnxDataWithGroupAddress:(NSString *)groupAddress objectValue:(NSString *)value valueLength:(NSString *)valueLength commandType:(NSString *)commandType
{
    
    //                           0           1           2           3           4           5           6           7           8           9
    unsigned char eibIntValue[72] = {0x00, 0x00, 0x00, 0x64, 0x08, 0x64, 0x01, 0x2C, 0x10, 0x64, 0x01, 0xF4, 0x02, 0x58, 0x02, 0xBC, 0x18, 0x64, 0x03, 0x84,\
        0x03, 0xE8, 0x04, 0x4C, 0x04, 0xB0, 0x05, 0x14, 0x05, 0x78, 0x05, 0xDC, 0x06, 0x40, 0x06, 0xA4, 0x07, 0x08, 0x07, 0x6C,\
        0x07, 0xD0, 0x0C, 0x1A, 0x0C, 0x4C, 0x0C, 0x7E, 0x0C, 0xB0, 0x0C, 0xE2, 0x0D, 0x14, 0x0D, 0x46, 0x0D, 0x78, 0x0D, 0xAA,\
        0x0D, 0xDC, 0x0E, 0x0E, 0x0E, 0x40, 0x0E, 0x72, 0x0E, 0xA4, 0x0E, 0xD6};
    
    NSInteger dataLength = 0;
    
    if (connectStatus == 0)
    {
        return;
    }
    
    //NSInteger outputValue = [value integerValue];
    NSArray *groupAddressSplit = [groupAddress componentsSeparatedByString:@"/"];
    
    Byte sendByte[] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x00,0x01,0x00,0x81,0x00,0x00};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    
    
    sendByte[16] = ([[groupAddressSplit objectAtIndex:0] integerValue] << 3 ) | ([[groupAddressSplit objectAtIndex:1] integerValue] & 0x07);
    sendByte[17] = [[groupAddressSplit objectAtIndex:2] integerValue];
    
    if ([commandType isEqualToString:@"Write"])
    {
        if ([valueLength isEqualToString:@"1Bit"])
        {
            sendByte[5] = 0x15;//package length
            sendByte[18] = 1;//value length
            sendByte[20] = 0x80 | ([value integerValue] & 0x01);
            dataLength = 21;
            //SC++;
        }
        else if ([valueLength isEqualToString:@"1Byte"])
        {
            sendByte[5] = 0x16;//package length
            sendByte[18] = 2;//value length
            sendByte[20] = 0x80;
            sendByte[21] = [value integerValue];
            dataLength = 22;
            //SC++;
        }
        else if ([valueLength isEqualToString:@"2Byte"])
        {
            if ([value integerValue] < 0 || [value integerValue] > 36)
            {
                return;
            }
            
            sendByte[5] = 0x17;//package length
            sendByte[18] = 3;//value length
            sendByte[20] = 0x80; //apci
            sendByte[21] = eibIntValue[[value integerValue] * 2]; //value
            sendByte[22] = eibIntValue[[value integerValue] * 2 + 1]; //value
            dataLength = 23;
            //SC++;
        }
        
    }
    else if ([commandType isEqualToString:@"Read"])
    {
        //if ([valueLength isEqualToString:@"1Bit"])
        {
            sendByte[5] = 0x15;//package length
            sendByte[18] = 1;//value length
            sendByte[20] = 0x00 | ([value integerValue] & 0x01);
            dataLength = 21;
            //SC++;
        }
    }
    
    
    SC++;
    data = [NSMutableData dataWithBytes:sendByte length:dataLength];
    
    [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
    //NSLog(@"SENT (%i): Set Light A %u", (int)tag, sendByte[20] & 0x01);
    tag++;

}

#pragma mark GCDAsyncUdpSocket Delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    // You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    //NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    Byte *testByte = (Byte *)[data bytes];
    //atos();
    //NSString *msg = [[NSString alloc] initWithBytes:testByte length:[data length] encoding:NSUnicodeStringEncoding];
    
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",testByte[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    
    if (hexStr)
    {
        //[self logMessage:FORMAT(@"RECV: %@", hexStr)];  //CID
        
        if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x00))
        {
            CID = testByte[6];
            connectStatus = 1;
            [udpHeartBeat setFireDate:[NSDate distantPast]];  //start heart beat
            NSLog(@"Connect Sucess CID : %u", CID);  //CID
            
//            Byte sendByte[] = {0x06,0x10,0x04,0x20,0x00,0x15,0x04,CID,SC,0x00,0x11,0x00,0xbc,0xd0,0x00,0x00,0x18,0x0c,0x01,0x00,0x00}; //read
//            SC++;
//            NSMutableData *data = [[NSMutableData alloc] init];
//            
//            data = [NSMutableData dataWithBytes:sendByte length:21];
//            
//            [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
//            NSLog(@"SENT (%i): Read Light A Status CID %u  SC %u", (int)tag, CID, SC);
//            tag++;
            
            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x06) && (testByte[7] == 0x24))
        {
            NSLog(@"Connect Failed  E_NO_MORE_CONNECTIONS");  //CID
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x0A))
        {
            if (testByte[6] == CID)
            {
                connectStatus = 0;
                SC = 0;
                [udpHeartBeat setFireDate:[NSDate distantFuture]]; //stop heart beat
                NSLog(@"Disconnect  CID : %u", CID);  //CID
            }
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x02) && (testByte[3] == 0x08))
        {
            if (testByte[6] == CID)
            {
                if (testByte[7] == 0x00)
                {
                    //[self logMessage:FORMAT(@"Connection State Response OK  CID : %u", CID)];  //CID
                    NSLog(@"Connection State Response OK  CID : %u", CID);  //CID
                    return;
                }
                else
                {
                    connectStatus = 0;
                    [udpHeartBeat setFireDate:[NSDate distantFuture]];  //stop heart beat
                    NSLog(@"Connection State Error  CID : %u", CID);  //CID
                }
            }
            
        }
        else if ((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x20)) //request
        {
            //SC = testByte[8] + 1;
            
            Byte sendByte[] = {0x06,0x10,0x04,0x21,0x00,0x0a,0x04,CID,testByte[8],0x00};  //ack
            
            NSMutableData *data = [[NSMutableData alloc] init];
            
            data = [NSMutableData dataWithBytes:sendByte length:10];
            
            [TransmitUdpSocket sendData:data toHost:ipRouterHost port:ipRouterHostPort withTimeout:64 tag:tag];
            NSLog(@"SENT (%i): Connection ACK CID %u  SC %u", (int)tag, CID, SC);
            tag++;
            
            if ((testByte[19] == 0x00) && (testByte[20]  == 0x00))  //group value read
            {
                return;
            }
            
            NSString *groupAddress = [[NSString alloc] initWithFormat:@"%d/%d/%d",(testByte[16] >> 3), testByte[16] & 0x07,testByte[17]];
            NSString *value = nil;
            
            
            if (testByte[18] == 1) //1Bit
            {
                value = [[NSString alloc] initWithFormat:@"%d",testByte[20] & 0x01];
            }
            else if(testByte[18] == 2) //1Byte
            {
                value = [[NSString alloc] initWithFormat:@"%d",testByte[21]];
            }
            else if(testByte[18] == 3) //2Byte
            {
                float floatValueM = (testByte[21] & 0x07) << 8 | testByte[22];
                float floatValueE = (testByte[21] >> 3) & 0x0F;
                float tempValue = pow(2.0, floatValueE) * (floatValueM * 0.01);
                float tempValueInt = tempValue;
                value = [[NSString alloc] initWithFormat:@"%f",tempValueInt];
            }
            
            NSDictionary *eibBusDataDict = [NSDictionary dictionaryWithObjectsAndKeys:groupAddress, @"Address", value, @"Value",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BL.BLSmartPageViewDemo.RecvFromBus" object:self userInfo:eibBusDataDict];
            
//            //if ((testByte[16] == 0x18) && (testByte[17] == 0x0c))  //Light A State Response
//            {
////                if ((testByte[20] & 0x01))  //ON
////                {
////                    [uibLightA setHighlighted:YES];
////                    [uibLightA setSelected:YES];
////                }
////                else  //OFF
////                {
////                    [uibLightA setHighlighted:NO];
////                    [uibLightA setSelected:NO];
////                }
////                
////                [self logMessage:FORMAT(@"setHighlighted %u", (testByte[20] & 0x01))];
//                ß
//                
//            }
            
            
        }
        else if((testByte[0] == 0x06) && (testByte[1] == 0x10) && (testByte[2] == 0x04) && (testByte[3] == 0x21))//ack
        {
            NSLog(@"RECV (%i): Connection ACK CID %u  SC %u  Status %u", (int)tag, testByte[7], testByte[8], testByte[9]);
        }
        
    }
    else
    {
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"RECV: Unknown message from: %@:%hu", host, port);
    }
}

@end
