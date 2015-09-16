//
//  ViewController.m
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import "ViewController.h"
#import "APPChildViewController.h"
#import "AppDelegate.h"
#import "PropertyConfigPhrase.h"
#import "REMenu.h"
//#import <objc/runtime.h>
//@import CoreData;

@interface ViewController ()
{
    
//    NSMutableArray *objectTable;
//    NSMutableArray *associationTable;
//    NSMutableArray *writeToAddressTable;
//    NSMutableArray *readFromAddressTable;
//    NSMutableArray *writeToValueTable;
//    NSMutableArray *readFromValueTable;
    
    //REMenu *menu;
    //UITextField* groupAddressField;
    //UITextField* valueField;
}
@property (strong, readwrite, nonatomic) REMenu *menu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //add test Text Field
    //groupAddressField=[[UITextField alloc]initWithFrame:CGRectMake(150, 28, 100, 30)];
    //groupAddressField.borderStyle = UITextBorderStyleRoundedRect;//圆角
    //groupAddressField.placeholder = @"Add";
    
    //valueField=[[UITextField alloc]initWithFrame:CGRectMake(260, 28, 100, 30)];
    //valueField.borderStyle = UITextBorderStyleRoundedRect;//圆角
    //valueField.placeholder = @"Value";
    
    //[[self view] addSubview:groupAddressField];
    //[[self view] addSubview:valueField];
    
    
//add roomButtonList
    [self initRoomSelectButton];

    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    //self.pageController
    
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    //[[self.pageController view] setFrame:[[self view] bounds]];
    //[[self.pageController view] setFrame:CGRectMake(0, 44, 2048, 1492)];
    [[self.pageController view] setFrame:CGRectMake(0, 65, 1024, 703)];
    
    
    
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.viewControllerNavigationItemSharedInstance = self.viewControllerNavigationItem;
    
    //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #0"];
    
    
    PropertyConfigPhrase *sceneConfig = [[PropertyConfigPhrase alloc] init];
    [sceneConfig sceneListDictionary];
    
    self.sceneListDict = appDelegate.sceneListDictionarySharedInstance;
    sceneListCount = [self.sceneListDict count];
    
    self.viewControllerNavigationItem.title = [self.sceneListDict objectForKey:@"0"];
    
    APPChildViewController *initialViewController = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    
    
    
//    APPChildViewController *appChildViewControllerForGetWidget = [[APPChildViewController alloc] initWithNibName:@"LivingDiningRoom" bundle:nil];
//   
//    for (UIView *subView in appChildViewControllerForGetWidget.view.subviews)
//    {
//        if ([subView isMemberOfClass:[BLUIButton class]])
//        {
//            //subView.
//            //BLUIButton *button = (BLUIButton *) subView;
//            //NSManagedObject *managedObject = [[NSManagedObject alloc] initWith];
//            //NSManagedObject *button = (NSManagedObject *) subView;
//            //NSManagedObject *playlistContact;
//            //NSManagedObjectID *moID = [button objectID];
//            
//            //NSLog(@"subView ID = %@", moID);
//        }
//    }
    
    

    
    

    

    
    
    
    //self.viewControllerNavigationItemCollection.
    //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen ######"];
    //self.viewControllerNavigationItem.title.
    
    //self.navigationController.leftBarButtonItem

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(APPChildViewController *)viewController index];
    
    
    index++;
    //NSLog(@"scene list count = %d", sceneListCount);
    if (index == sceneListCount) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (APPChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    //APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:@"APPChildViewController" bundle:nil];
    
    //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //NSLog(@"%@", self.sceneListDict);
    //NSLog(@"%@", appDelegate.sceneListDictionarySharedInstance);
    
    NSLog(@"nib name = %@", [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%d", index]]);
    //NSLog(@"key = %@", [NSString stringWithFormat: @"%d", index]);
    //NSString *nibName = [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%d", index]];
    
    APPChildViewController *childViewController = [[APPChildViewController alloc] initWithNibName:[self.sceneListDict valueForKey:[NSString stringWithFormat: @"%d", index]] bundle:nil];
    
    //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #%ld", (long)index];
    childViewController.index = index;
    childViewController.nibName = [self.sceneListDict valueForKey:[NSString stringWithFormat: @"%d", index]];
    childViewController.pageController = self.pageController;
    childViewController.pageControllerDataSource = self;
    //[childViewController addChildViewController:self.pageController];
    
    return childViewController;
    
}

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0)
//{
//    //NSLog(@"22222222");
//    return;
//}


- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        int currentIndex = ((UIViewController *)[pageViewController.viewControllers objectAtIndex:0]).view.tag;
        
        //self.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen #%d", currentIndex];
        self.viewControllerNavigationItem.title = [self.sceneListDict objectForKey:[NSString stringWithFormat:@"%d", currentIndex]];
        //NSLog(@"completed index %d", currentIndex);
    }
}


//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
//    // The number of items reflected in the page indicator.
//    return 5;
//}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}


//- (IBAction)recvFromBusBtn:(id)sender
//{
//    
//    NSDictionary *eibBusDataDict = [NSDictionary dictionaryWithObjectsAndKeys:groupAddressField.text, @"Address", valueField.text, @"Value",nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"BL.BLSmartPageViewDemo.RecvFromBus" object:self userInfo:eibBusDataDict];
//}

- (void)initRoomSelectButton
{
    
    [self initNavigatorButtonItems];
    
//    //__typeof (self) __weak weakSelf = self;
//    REMenuItem *homeItem = [[REMenuItem alloc] initWithTitle:@"Home"
//                                                    subtitle:@"Return to Home Screen"
//                                                       image:[UIImage imageNamed:@"Icon_Home"]
//                                            highlightedImage:nil
//                                                      action:^(REMenuItem *item) {
//                                                          NSLog(@"Item: %@", item);
////                                                          XHomeViewController *controller = [[XHomeViewController alloc] init];
////                                                          [weakSelf setViewControllers:@[controller] animated:NO];
//                                                      }];
//    
//    homeItem.tag = 0;
//    
//    self.menu = [[REMenu alloc] initWithItems:@[homeItem]];
//    
//    if (!REUIKitIsFlatMode())
//    {
//        self.menu.cornerRadius = 4;
//        self.menu.shadowRadius = 4;
//        self.menu.shadowColor = [UIColor blackColor];
//        self.menu.shadowOffset = CGSizeMake(0, 1);
//        self.menu.shadowOpacity = 1;
//    }
//    
//    [self.menu setClosePreparationBlock:^{
//        NSLog(@"Menu will close");
//    }];
//    
//    [self.menu setCloseCompletionHandler:^{
//        NSLog(@"Menu did close");
//    }];
//    
//    [self.navigationController]


}

- (void) initNavigatorButtonItems
{
    UIButton * customRoomSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customRoomSelectButton.frame = CGRectMake(924, 28, 30, 30);
    [customRoomSelectButton setImage:[UIImage imageNamed:@"Icon_Home.png"] forState:UIControlStateNormal];
    //[customFloorSelectButton setTitle:@"Floor" forState:UIControlStateNormal];
    //[customFloorSelectButton setTitleEdgeInsets:UIEdgeInsetsMake(-1, -55, 0, 0)];
    //[customFloorSelectButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
    //[customFloorSelectButton setTitleColor:[UIColor colorWithRed:233.0/255.0 green:220.0/255.0 blue:207.0/255.0 alpha:1.0]forState:UIControlStateNormal];
    [customRoomSelectButton addTarget:self.navigationItem action:@selector(roomSelect:) forControlEvents:UIControlEventTouchUpInside];
    //UIBarButtonItem *roomSelectButton = [[UIBarButtonItem alloc] initWithCustomView:customRoomSelectButton];
    
    [[self view] addSubview:customRoomSelectButton];
    //[[self view] addSubview:valueField];

//    {
//        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self.navigationController action:nil];
//        negativeSpacer.width = 40;
//        self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:negativeSpacer, negativeSpacer, negativeSpacer, negativeSpacer, roomSelectButton, nil];
//    }
}

- (void)roomSelect:(UIButton *)sender
{
    CGRect buttonRect = sender.frame;
    NSLog(@"roomSelect @%f @%f", buttonRect.origin.x, buttonRect.origin.y);
//    if (self.menu.isOpen)
//        return [self.menu close];
    
    //[self.menu showFromNavigationController:self];
    //[self.menu showFromNavigationController:self withPressedButtonRect:buttonRect];
}
@end
