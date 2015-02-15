//
//  HHSDetailPager.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/12/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSTableViewController.h"

@interface HHSDetailPager : UIViewController

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic, weak) HHSCategoryVC *parent;
@property (nonatomic, weak) HHSArticleStore *articleStore;
@property (nonatomic) int startingArticleIndex;

@end
