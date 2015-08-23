//
//  APPChildViewController.h
//  BLSmartPageViewDemo
//
//  Created by Landyu on 15/8/7.
//  Copyright (c) 2015年 Landyu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLUIButton.h"

@interface APPChildViewController : UIViewController

//- (void)addChildViewController:(UIViewController *)childController;

@property (assign, nonatomic) NSInteger index;
@property (copy, nonatomic) NSString* nibName;
@property (strong, nonatomic) IBOutlet UILabel *screenNumber;
- (IBAction)testButton:(UIButton *)sender;

- (IBAction)buttonPressd:(BLUIButton *)sender;


@end
