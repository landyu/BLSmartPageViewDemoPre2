//
//  APPChildViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "APPChildViewController.h"
#import "ViewController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "BLUISwitch.h"
#import "BLUISceneButton.h"



@interface APPChildViewController ()
{
    //dispatch_queue_t transmitActionQueue;
    //NSMutableArray * childTransmitDataFIFO;
    AppDelegate *appDelegate;
    //NSString *widgetPlistPath;
    NSMutableDictionary *nibPlistDict;
}

@end

@implementation APPChildViewController
@synthesize nibName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.view.tag = self.index;
    
    NSLog(@"view count = %d", self.view.subviews.count);
    
    appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //transmitActionQueue = appDelegate.transmitQueue;
    //childTransmitDataFIFO = appDelegate.transmitDataFIFO;
    
    NSString *widgetPlistPath = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    dispatch_async([Utils GlobalUserInitiatedQueue],
                   ^{
                       [self getAllWidgetsStatus];
                   });
    
    
    //appDelegate.viewControllerNavigationItemSharedInstance = self.viewControllerNavigationItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"BL.BLSmartPageViewDemo.RecvFromBus" object:nil];
    
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isMemberOfClass:[BLUISwitch class]])
        {
            BLUISwitch *switchButton = (BLUISwitch *) subView;
            
            [switchButton addTarget:self action:@selector(switchButtonPressd:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else if ([subView isMemberOfClass:[BLUISceneButton class]])
        {
            BLUISceneButton *sceneButton = (BLUISceneButton *) subView;
            
            [sceneButton addTarget:self action:@selector(sceneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self parseSceneButtonWithNibPlistDict:nibPlistDict object:sceneButton];
        }
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark Switch Button

- (void)switchButtonPressd:(BLUISwitch *)sender {
    
    //__block NSInteger transmitValue;
    
    NSLog(@"SwitchButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!nibPlistDict) {
        return;
    }
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         
         //NSLog(@"dict[%@] = %@", key, temDict[key]);
         //NSString *objectName = (NSString *)key;
         if ([key isEqualToString:sender.objName])
         {
             NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:nibPlistDict[key]];
             [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
              {
                  if ([key isEqualToString:@"WriteToGroupAddress"])
                  {
                      NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                      NSMutableDictionary *writeToGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                      [writeToGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                       {
                           [self parseDataForPreTransmitWithObject:sender destGroupAddress:writeToGroupAddressDict[key] buttonName:sender.objName valueLength:valueLength objectPropertyDictionay:objectPropertyDict];
                       }];
                  }
              }];
         }
     }];
}

- (void) parseDataForPreTransmitWithObject:(BLUISwitch *)obj destGroupAddress:(NSString *)destGroupAddress buttonName:(NSString *)buttonName valueLength:(NSString *)valueLength objectPropertyDictionay:(NSMutableDictionary *)objectPropertyDict
{
    //NSLog(@"writeToGroupAddressDict[%@] = %@", key, writeToGroupAddressDict[key]);
    __block NSInteger transmitValue;
    
    if ([valueLength isEqualToString:@"1Bit"])
    {
        if ([obj isSelected])
        {
            transmitValue = 0;
        }
        else
        {
            transmitValue = 1;
        }
        
    }
    else if([valueLength isEqualToString:@"1Byte"])
    {
        [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             if ([key isEqualToString:@"WriteToValue"])
             {
                 transmitValue = [(NSString *)obj integerValue];
             }
         }];
    }
    else
    {
        return;
    }
    
    [self blUIButtonTransmitActionWithDestGroupAddress:destGroupAddress value:transmitValue buttonName:buttonName valueLength:valueLength];
}

#pragma mark Scene Button
- (void) sceneButtonPressed:(BLUISceneButton *)sender
{
    //__block NSInteger transmitValue;
    
    NSLog(@"SceneButtonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    
    
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    dispatch_async([Utils GlobalBackgroundQueue],
    ^{
        [sender.sceneSequenceMutableDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
         {
             NSDictionary *sceneDict = (NSDictionary *)obj;
             [self blUIButtonTransmitActionWithDestGroupAddress:sceneDict[@"WriteToGroupAddress"] value:[sceneDict[@"Value"] integerValue] buttonName:sender.objName valueLength:sceneDict[@"ValueLength"]];
             [NSThread sleepForTimeInterval:[sender.sceneDelayDuration doubleValue]];
         }];
    });
    
}

- (void) parseSceneButtonWithNibPlistDict:(NSMutableDictionary *)xibPlistDict object:(BLUISceneButton *)sceneButton
{
    if (!nibPlistDict) {
        return;
    }

    [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         
         if ([key isEqualToString:sceneButton.objName])
         {
             NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:nibPlistDict[key]];
             sceneButton.sceneDelayDuration = [NSNumber numberWithFloat:[objectPropertyDict[@"SceneDelayDuration"] floatValue]];
             sceneButton.sceneSequenceMutableDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[@"Scene"]];
             //sceneButton.sceneCount = [sceneButton.sceneSequenceMutableDict count];
         }
     }];

}

#pragma mark Send Write Command
- (void) blUIButtonTransmitActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{

    NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%d", value], @"Value", valueLength, @"ValueLength", @"Write", @"CommandType", nil];
    [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
}

#pragma mark Receive From Bus
- (void) recvFromBus: (NSNotification*) notification
{
    NSDictionary *dict = [notification userInfo];
    NSLog(@"receive data from bus at NibName = %@ Scene %d dict = %@", self.nibName,self.index, dict);
    [self actionWithGroupAddress:dict[@"Address"] withObjectValue:[dict[@"Value"] intValue]];
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (void)actionWithGroupAddress:(NSString *)groupAddress withObjectValue:(NSInteger)objectValue
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!nibPlistDict) {
        return;
    }
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        
        //NSLog(@"dict[%@] = %@", key, temDict[key]);
        NSString *objectName = (NSString *)key;
        
        NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:nibPlistDict[key]];
        [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            if ([key isEqualToString:@"ReadFromGroupAddress"])
            {
                NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                {
                    NSLog(@"readFromGroupAddressDict[%@] = %@", key, readFromGroupAddressDict[key]);
                    if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                    {

                        [self checkSubViewClassMemberAndActionWithGroupAddress:groupAddress withObjectValue:objectValue withObjectName:objectName withValueLength:valueLength];

                    }
                }];
            }
        }];
    }];
    
}

- (void)checkSubViewClassMemberAndActionWithGroupAddress:(NSString *)groupAddress withObjectValue:(NSInteger)objectValue withObjectName:(NSString *)objectName withValueLength:(NSString *)valueLength
{
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isMemberOfClass:[BLUISwitch class]])
        {
            BLUISwitch *button = (BLUISwitch *) subView;
            [self blUIButtonUpdateActionWithButtonObject:button buttonValue:objectValue buttonName:objectName valueLength:valueLength];
        }
        
    }
}

- (void) blUIButtonUpdateActionWithButtonObject:(BLUISwitch *)button buttonValue:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    if ([button.objName isEqualToString:name])
    {
        if ([valueLength isEqualToString:@"1Bit"])
        {
            if (value == 1)
            {
                [button setSelected:YES];
            }
            else if(value == 0)
            {
                [button setSelected:NO];
            }
        }
    }

}

#pragma mark Init Widgets Status

-(void) getAllWidgetsStatus
{
    //NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!nibPlistDict) {
        return;
    }
    //NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:widgetPlistPath];
    
    
    //__block NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:temDict[key]];
    [nibPlistDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         
         NSMutableDictionary *objectPropertyDict = [[NSMutableDictionary alloc] initWithDictionary:nibPlistDict[key]];
         [objectPropertyDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
          {
              if ([key isEqualToString:@"ReadFromGroupAddress"])
              {
                  NSString *valueLength = [[NSString alloc]initWithString:objectPropertyDict[@"ValueLength"]];
                  NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                  [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                   {
                       NSLog(@"readFromGroupAddressDict[%@] = %@", key, readFromGroupAddressDict[key]);

                       NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:readFromGroupAddressDict[key], @"GroupAddress", valueLength, @"ValueLength", @"Read", @"CommandType", nil];
                       [appDelegate pushDataToFIFOThreadSaveAndSendNotificationAsync:transmitDataDict];
                   }];
              }
          }];
     }];
}

@end
