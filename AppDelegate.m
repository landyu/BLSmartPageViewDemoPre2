//
//  AppDelegate.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "AppDelegate.h"
#import "TransmitUdp.h"
#import "Utils.h"

@interface AppDelegate ()
{
    TransmitUdp *transmitUdpHandle;
}

@end



@implementation AppDelegate
@synthesize viewControllerNavigationItemSharedInstance;
@synthesize sceneListDictionarySharedInstance;
@synthesize transmitDataFIFO;



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    viewControllerNavigationItemSharedInstance = nil;
    sceneListDictionarySharedInstance = nil;
    concurrentWriteToBusDataProcessQueue = nil;
    concurrentWriteToBusDataProcessQueue = dispatch_queue_create("BL.BLSmartPageViewDemo.WriteToBusDataProcessQueue", DISPATCH_QUEUE_CONCURRENT);
    serialUdpWriteToBusQueue = nil;
    serialUdpWriteToBusQueue = dispatch_queue_create("BL.BLSmartPageViewDemo.UdpWriteToBusQueue", DISPATCH_QUEUE_SERIAL);
    transmitDataFIFO = nil;
    transmitDataFIFO = [NSMutableArray array];
    /// Notification when content updates (i.e. Download finishes)
    TransmitQueueDataUpdateNotification = @"BL.BLSmartPageViewDemo.TransmitQueueDataUpdate";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeToBus:) name:TransmitQueueDataUpdateNotification object:nil];
    
    transmitUdpHandle = [TransmitUdp sharedInstance];
    
//    if ((transmitDataFIFO != nil) && (transmitQueue != nil))
//    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            // 耗时的操作
//            while (TRUE)
//            {
//                if ([transmitDataFIFO count] == 0)
//                {
//                    [NSThread sleepForTimeInterval:0.01];
//                    continue;
//                }
//                NSDictionary *transmitData = [transmitDataFIFO queuePop];
//                //NSLog(@"transmitData = %@", [transmitDataFIFO queuePop]);
//
//                [transmitUdpHandle sendKnxDataWithGroupAddress:[transmitData objectForKey:@"GroupAddress"] objectValue:[transmitData objectForKey:@"Value"]];
//            };
//        });
//
//    }
        return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [transmitUdpHandle disconnectDevice];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    transmitUdpHandle = [TransmitUdp sharedInstance];
    if ([transmitUdpHandle udpSocketisClosed])
    {
        [transmitUdpHandle setupSocket];
        [transmitUdpHandle connectDevice];
    }
    else
    {
        [transmitUdpHandle connectDevice];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (![transmitUdpHandle udpSocketisClosed])
    {
        [transmitUdpHandle closeSocket];
    }

    
}

- (void)writeToBus:(NSNotification*) notification
{
    
    while ([transmitDataFIFO count])
    {
        NSDictionary *dataWriteToBus = [self popDataFromFIFOThreadSave];
        //NSLog(@"transmitData = %@", [transmitDataFIFO queuePop]);
        dispatch_async(serialUdpWriteToBusQueue,
                       ^{
                           [transmitUdpHandle sendKnxDataWithGroupAddress:[dataWriteToBus objectForKey:@"GroupAddress"] objectValue:[dataWriteToBus objectForKey:@"Value"]];
                       });
        
    };
}

-(void)pushDataToFIFOThreadSaveAndSendNotificationAsync:(id)value
{
    dispatch_barrier_async(concurrentWriteToBusDataProcessQueue,
    ^{
        [self.transmitDataFIFO queuePush:value];
        dispatch_async([Utils GlobalMainQueue],
                       ^{
                           [self postTransmitQueueDataUpdateNotification];
                       });
    });

}

-(NSDictionary *)popDataFromFIFOThreadSave
{
    __block NSDictionary *dataCopy;
    dispatch_barrier_sync(concurrentWriteToBusDataProcessQueue,
                  ^{
                      dataCopy = [self.transmitDataFIFO queuePop];
                  });
    return dataCopy;
}

-(void)postTransmitQueueDataUpdateNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TransmitQueueDataUpdateNotification object:nil];
}


@end
