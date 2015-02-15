//
//  HHSMainPager.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSMainViewController.h"

@interface HHSMainPager : UIViewController
@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, weak) HHSMainViewController *parent;
@property (nonatomic) int startingPage;


@end
