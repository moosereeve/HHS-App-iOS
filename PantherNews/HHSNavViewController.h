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
@class HHSSchedulesVC;
@class HHSDailyAnnVC;
@class HHSEventsVC;
@class HHSNewsVC;
@class HHSLunchVC;
@class HHSCategoryVC;
@class HHSHomeViewController;

@interface HHSNavViewController : UIViewController <UIPageViewControllerDataSource>
@property (nonatomic) HHSCategoryVC *currentView;
@property (nonatomic, strong) NSDictionary *tableviews;
@property (nonatomic) BOOL schedulesDownloaded;
@property (nonatomic) BOOL eventsDownloaded;
@property (nonatomic) BOOL newsDownloaded;
@property (nonatomic) BOOL dailyAnnDownloaded;
@property (nonatomic) BOOL lunchDownloaded;

@property (nonatomic, strong) HHSArticleStore *schedulesStore;
@property (nonatomic, strong) HHSArticleStore *eventsStore;
@property (nonatomic, strong) HHSArticleStore *newsStore;
@property (nonatomic, strong) HHSArticleStore *dailyAnnStore;
@property (nonatomic, strong) HHSArticleStore *lunchStore;

@property (nonatomic, strong) HHSHomeViewController *homeVC;
@property (nonatomic, strong) HHSSchedulesVC *schedulesTVC;
@property (nonatomic, strong) HHSEventsVC *eventsTVC;
@property (nonatomic, strong) HHSNewsVC *newsTVC;
@property (nonatomic, strong) HHSDailyAnnVC *dailyAnnTVC;
@property (nonatomic, strong) HHSLunchVC *lunchTVC;

-(void)refreshStores;
-(void)refreshViews;
-(void)notifyStoreIsReady:(HHSArticleStore *)store;
-(void)notifyStoreDownloadError:(HHSArticleStore *)store error:(NSString *)error;
-(void)refreshDone:(int)type;
-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
-(void)showWaitingWithText:(NSString *)text buttonText:(NSString *)buttonText;
-(void)hideWaiting;
-(UIViewController *)viewControllerAtIndex:(int)index;
@end
