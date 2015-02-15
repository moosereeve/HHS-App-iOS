//
//  HHSCategoryVC.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"
#import "HHSMainViewController.h"
@class HHSArticle;

@interface HHSCategoryVC : UIViewController<UISplitViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic) int pagerIndex;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) HHSArticleStore *articleStore;
@property (nonatomic) NSMutableArray *articlesList;
@property (nonatomic, strong) NSMutableArray *sectionGroups;
@property (nonatomic) int numberOfSections;

@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic, weak) HHSMainViewController *owner;
@property BOOL viewLoaded;

//@property (nonatomic, copy) NSArray *articles;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

-(instancetype)initWithStore:(HHSArticleStore *)store;
-(void)reloadArticlesFromStore;
-(void)downloadError;
-(UIViewController *)viewControllerAtIndex:(int)index;
-(void)sendToDetailPager:(int)index parentViewController:(HHSCategoryVC *)viewController;


@end
