//
//  HHSHomeViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 7/23/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"
#import "HHSCalendarStore.h"
#import "HHSNewsStore.h"
#import "HHSCategoryVC.h"

@interface HHSHomeViewController : UIViewController <UITableViewDelegate, UISplitViewControllerDelegate>

@property (nonatomic) int pagerIndex;
@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic, weak) HHSMainViewController *owner;
@property BOOL isViewLoaded;

@property (nonatomic, weak) HHSCalendarStore *schedulesStore;
@property (nonatomic, weak) HHSNewsStore *newsStore;
@property (nonatomic, weak) HHSCalendarStore *eventsStore;
@property (nonatomic, weak) HHSArticleStore *dailyAnnStore;
@property (nonatomic, weak) HHSCalendarStore *lunchStore;

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
