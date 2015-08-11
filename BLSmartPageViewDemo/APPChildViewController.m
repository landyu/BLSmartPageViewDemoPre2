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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.screenNumber.text = [NSString stringWithFormat:@"Screen #%ld", (long)self.index];
    //ViewController.viewControllerNavigationItem.title = [NSString stringWithFormat:@"Screen ######"];
    
    //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    //if(appDelegate.viewControllerNavigationItemSharedInstance != nil)
    {
        //appDelegate.viewControllerNavigationItemSharedInstance.title = self.screenNumber.text;
    }
    
//    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"homeDemo.png"]];
//    backgroundView.contentMode = UIViewContentModeScaleToFill;
//    CGRect frame = backgroundView.frame;
//    frame.size.width = 1024;
//    frame.size.height = 703;
//    backgroundView.frame = frame;
//    [self.view addSubview:backgroundView];
//    [self.view sendSubviewToBack:backgroundView];
    self.view.tag = self.index;
    
    
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
@end
