//
//  HHSHomeViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 7/23/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"
#import "HHSCategoryVC.h"

@interface HHSHomeViewController : UIViewController <UITableViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic) int pagerIndex;
@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic, weak) HHSMainViewController *owner;
@property BOOL viewLoaded;

@property (nonatomic, weak) HHSArticleStore *schedulesStore;
@property (nonatomic, weak) HHSArticleStore *newsStore;
@property (nonatomic, weak) HHSArticleStore *eventsStore;
@property (nonatomic, weak) HHSArticleStore *dailyAnnStore;
@property (nonatomic, weak) HHSArticleStore *lunchStore;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *schedTitle;
@property (weak, nonatomic) IBOutlet UILabel *schedDate;
@property (weak, nonatomic) IBOutlet UIImageView *schedIcon;

@property (weak, nonatomic) IBOutlet UILabel *lunchTitle;

@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;

@property (weak, nonatomic) IBOutlet UILabel *dailyAnnTitle;

@property (weak, nonatomic) IBOutlet UIView *eventsBox;

-(void) fillAll;
-(void) fillSchedule;
-(void) fillEvents;
-(void) fillNews;
-(void) fillDailyAnn;
-(void) fillLunch;

-(void)sendToDetailPager:(int)index parentViewController:(HHSCategoryVC *)viewController;
-(void)beginRefreshingView;

@end
