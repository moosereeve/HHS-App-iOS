//
//  HHSMainViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

@protocol HHSMainViewDelegate <NSObject>
-(void)refreshDone:(int)type;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end

#import <UIKit/UIKit.h>
@class HHSArticleStore;
@class HHSSchedulesVC;
@class HHSDailyAnnVC;
@class HHSEventsVC;
@class HHSNewsVC;
@class HHSLunchVC;
@class HHSCategoryVC;
@class HHSHomeViewController;
#import "SWRevealViewController.h"

@interface HHSMainViewController : UIViewController
<UIPageViewControllerDataSource, UISplitViewControllerDelegate>

@property (nonatomic, strong) SWRevealViewController *swViewController;

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
-(void)jumpToPage:(int) index;
-(void)refreshDataButtonPushed;
@end
