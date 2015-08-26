//
//  TransmitUdp.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/25.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TransmitUdp : NSObject
+ (TransmitUdp *)sharedInstance;
- (void)setupSocket;
- (void)closeSocket;
- (BOOL)udpSocketIsConnected;
- (BOOL)udpSocketisClosed;
- (void)connectDevice;
- (void)disconnectDevice;

@end
