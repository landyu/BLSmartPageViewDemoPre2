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

@end

@implementation APPChildViewController
@synthesize nibName;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];

    self.view.tag = self.index;
    
    NSLog(@"view count = %d", self.view.subviews.count);
    
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
    NSLog(@"buttonPressd #%ld, objName = %@", (long)self.index, sender.objName);
    
    
    
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
    [self actionWithGroupAddress:dict[@"Address"] withObjectValue:dict[@"Value"]];
}

//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


- (void)actionWithGroupAddress:(NSString *)groupAddress withObjectValue:(NSString *)objectValue
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
                NSMutableDictionary *readFromGroupAddressDict = [[NSMutableDictionary alloc] initWithDictionary:objectPropertyDict[key]];
                [readFromGroupAddressDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
                {
                    NSLog(@"readFromGroupAddressDict[%@] = %@", key, readFromGroupAddressDict[key]);
                    if ([readFromGroupAddressDict[key] isEqualToString:groupAddress])
                    {

                        for (UIView *subView in self.view.subviews)
                        {
//                            if (<#condition#>) {
//                                <#statements#>
//                            }
                            if ([subView isMemberOfClass:[BLUIButton class]])
                            {
                                BLUIButton *button = (BLUIButton *) subView;
                                if ([button.objName isEqualToString:objectName])
                                {
                                    if ([objectValue isEqualToString:@"1"])
                                    {
                                        [button setSelected:YES];
                                    }
                                    else if([objectValue isEqualToString:@"0"])
                                    {
                                        [button setSelected:NO];
                                    }
                                }
                                
                            }
                            
                        }

                    }
                }];
            }

        }];

        
        
    }];

//    self.sceneListMutDict = [[NSMutableDictionary alloc] initWithDictionary:[temDict objectForKey:@"SceneList"]];
//    
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    appDelegate.sceneListDictionarySharedInstance = self.sceneListMutDict;
    
}

@end
