//
//  HHSNavViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

@protocol HHSNavViewControllerDelegate <NSObject>
-(void)refreshDone:(int)type;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end

#import <UIKit/UIKit.h>
//#import "HHSTableViewController.h"
//#import "HHSHomeViewController.h"
@class HHSArticleStore;
@class HHSScheduleTableViewController;
@class HHSDailyAnnTableViewController;
@class HHSEventsTableViewController;
@class HHSNewsTableViewController;

@class HHSTableViewController;
@class HHSHomeViewController;

@interface HHSNavViewController : UIViewController 
@property (nonatomic) HHSTableViewController *tableViewController;
@property (nonatomic, strong) NSDictionary *tableviews;
@property (nonatomic) BOOL schedulesDownloaded;
@property (nonatomic) BOOL eventsDownloaded;
@property (nonatomic) BOOL newsDownloaded;
@property (nonatomic) BOOL dailAynnDownloaded;

@property (nonatomic, strong) HHSArticleStore *schedulesStore;
@property (nonatomic, strong) HHSArticleStore *eventsStore;
@property (nonatomic, strong) HHSArticleStore *newsStore;
@property (nonatomic, strong) HHSArticleStore *dailyAnnStore;

@property (nonatomic, strong) HHSHomeViewController *homeVC;
@property (nonatomic, strong) HHSScheduleTableViewController *schedulesTVC;
@property (nonatomic, strong) HHSEventsTableViewController *eventsTVC;
@property (nonatomic, strong) HHSNewsTableViewController *newsTVC;
@property (nonatomic, strong) HHSDailyAnnTableViewController *dailyAnnTVC;


-(void)refreshDone:(int)type;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end
