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



@interface APPChildViewController ()
{
    dispatch_queue_t transmitActionQueue;
    NSMutableArray * childTransmitDataFIFO;
}

@end

@implementation APPChildViewController
@synthesize nibName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];

    self.view.tag = self.index;
    
    NSLog(@"view count = %d", self.view.subviews.count);
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    transmitActionQueue = appDelegate.transmitQueue;
    childTransmitDataFIFO = appDelegate.transmitDataFIFO;
    
    
    //appDelegate.viewControllerNavigationItemSharedInstance = self.viewControllerNavigationItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recvFromBus:) name:@"RecvFromBus" object:nil];
    
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isMemberOfClass:[BLUIButton class]])
        {
            BLUIButton *button = (BLUIButton *) subView;
            
            [button addTarget:self action:@selector(buttonPressd:) forControlEvents:UIControlEventTouchUpInside];
            
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


//- (void)addChildViewController:(UIViewController *)childController
//{
//    [self addChildViewController:childController];
//}

//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
//{
//    
//    NSLog(@"111111111");
////    if (completed) {
////        int currentIndex = ((UIViewController *)[self.pageController.viewControllers objectAtIndex:0]).view.tag;
////        self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #%d", currentIndex];
////    }
//}

- (IBAction)testButton:(UIButton *)sender {
    NSLog(@"Screen #%ld", (long)self.index);
}

- (IBAction)buttonPressd:(BLUIButton *)sender {
    
    __block NSInteger transmitValue;
    
    NSLog(@"buttonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!path) {
        return;
    }
    NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
    
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
                           //NSLog(@"writeToGroupAddressDict[%@] = %@", key, writeToGroupAddressDict[key]);
                           if ([valueLength isEqualToString:@"1Bit"])
                           {
                               if ([sender isSelected])
                               {
                                   transmitValue = 0;
                               }
                               else
                               {
                                   transmitValue = 1;
                               }
                               [self blUIButtonTransmitActionWithDestGroupAddress:writeToGroupAddressDict[key] value:transmitValue buttonName:sender.objName valueLength:valueLength];
                           }
                       }];
                  }
              }];
         }
         

     }];
    
//    if (sender.selected == YES)
//    {
//        [sender setSelected:NO];
//    }
//    else
//    {
//        [sender setSelected:YES];
//    }
}


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
    NSString *path = [[NSBundle mainBundle] pathForResource:self.nibName ofType:@"plist"];
    
    if (!path) {
        return;
    }
    NSMutableDictionary *nibPlistDict = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
    
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
        if ([subView isMemberOfClass:[BLUIButton class]])
        {
            BLUIButton *button = (BLUIButton *) subView;
            [self blUIButtonUpdateActionWithButtonObject:button buttonValue:objectValue buttonName:objectName valueLength:valueLength];
        }
        
    }
}

- (void) blUIButtonUpdateActionWithButtonObject:(BLUIButton *)button buttonValue:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
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

- (void) blUIButtonTransmitActionWithDestGroupAddress:(NSString *)destGroupAddress value:(NSInteger)value buttonName:(NSString *)name valueLength:(NSString *)valueLength
{
    //NSLog(@"destGroupAddress = %@, value = %d, name = %@, valueLength = %@", destGroupAddress, value, name, valueLength);
    if ((transmitActionQueue == nil) || (childTransmitDataFIFO == nil))
    {
        return;
    }
    NSDictionary *transmitDataDict = [[NSDictionary alloc] initWithObjectsAndKeys:destGroupAddress, @"GroupAddress",  [NSString stringWithFormat: @"%d", value], @"Value", valueLength, @"ValueLength", nil];
    dispatch_async(transmitActionQueue, ^{ NSLog(@"destGroupAddress = %@, value = %d, name = %@, valueLength = %@", destGroupAddress, value, name, valueLength); });
    dispatch_async(transmitActionQueue, ^{ [childTransmitDataFIFO queuePush:transmitDataDict];});
}

@end
