//
//  HHSNavViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSNavViewController.h"
#import "HHSMainPager.h"
#import "HHSHomeViewController.h"
#import "HHSSchedulesVC.h"
#import "HHSDailyAnnVC.h"
#import "HHSEventsVC.h"
#import "HHSNewsVC.h"
#import "HHSLunchVC.h"
#import "HHSArticleStore.h"
#import "APLParseOperation.h"
#import "HHSNavigationControllerForSplitView.h"

@interface HHSNavViewController ()
@property (nonatomic, strong) HHSMainPager *pager;
@property (nonatomic, strong) UIPopoverController *currentPopover;
@property (nonatomic, strong) UIAlertView *alert;
@property BOOL errorShowing;

@end

@implementation HHSNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"NavViewController init started");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Holliston High School";
        
        [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor blackColor],}];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed: (181/255.0) green:(30/255.0) blue:(18/255.0) alpha:(128/255.0)]];
        
        self.navigationController.navigationBar.translucent = YES;
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Menu" style: UIBarButtonItemStyleBordered target: nil action: nil];
        
        [self.navigationItem setBackBarButtonItem: backButton];

        _homeVC = [[HHSHomeViewController alloc] init];
        [self setUpSchedules];
        [self setUpNews];
        [self setUpEvents];
        [self setUpDailyAnn];
        [self setUpLunch];
        [self setUpHome];
        
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    [self jumpToPage:0];
    //[self goToHome:nil];
}

-(void)setUpSchedules
{
    //these are values that the parser will scan for
    NSDictionary *parserNames = @{@"entry" : @"",
                                  @"date" : @"start",
                                  @"startTime" : @"",
                                  @"title" : @"summary",
                                  @"link" : @"htmlLink",
                                  @"details" : @"description",
                                  @"keepHtmlTags" : @""};
    
    NSString *feedUrlString = @"https://www.googleapis.com/calendar/v3/calendars/sulsp2f8e4npqtmdp469o8tmro%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=AIzaSyBsDse7YteqjWWEJpvAzxt3ZVToXSfjTEY";

    //initialize stores
    _schedulesStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeSchedules]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       sortNowToFuture:(BOOL)YES
                       owner:self];
    
    _schedulesTVC = [[HHSSchedulesVC alloc] initWithStore:_schedulesStore];
    _schedulesTVC.owner = self;
    _schedulesTVC.pagerIndex = 1;
    [_schedulesTVC view];
    
    
}

-(void)setUpEvents
{
    //these are values that the parser will scan for
    
    NSDictionary *parserNames = @{@"entry" : @"",
                                  @"date" : @"start",
                                  @"startTime" : @"",
                                  @"title" : @"summary",
                                  @"link" : @"htmlLink",
                                  @"details" : @"description",
                                  @"keepHtmlTags" : @""};

    
    NSString *feedUrlString = @"https://www.googleapis.com/calendar/v3/calendars/holliston.k12.ma.us_gsfpbqnefkm59ul6gbofte1s2k%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=AIzaSyBsDse7YteqjWWEJpvAzxt3ZVToXSfjTEY";

    //initialize stores
    _eventsStore = [[HHSArticleStore alloc]
                      initWithType:[HHSArticleStore HHSArticleStoreTypeEvents]
                      parserNames:parserNames
                      feedUrlString:feedUrlString
                      sortNowToFuture:YES
                      owner:self];

    _eventsTVC = [[HHSEventsVC alloc] initWithStore:_eventsStore];
    _eventsTVC.owner = self;
    
    _eventsTVC.pagerIndex = 4;
    [_eventsTVC view];
    
}

-(void)setUpNews
{
    //these are values that the parser will scan for
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"updated",
                                  @"startTime" : @"",
                                  @"title" : @"title",
                                  @"link" : @"link",
                                  @"details" : @"content",
                                  @"keepHtmlTags" : @"keep"};
    
    NSString *feedUrlString = @"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/general-info/news/posts.xml";
    
    //initialize stores
    _newsStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeNews]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       sortNowToFuture:NO
                       owner:self];
    
    _newsTVC = [[HHSNewsVC alloc] initWithStore:_newsStore];
    _newsTVC.owner = self;
    _newsTVC.pagerIndex = 2;
    [_newsTVC view];
}
-(void)setUpDailyAnn
{
    //these are values that the parser will scan for
    
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"published",
                                  @"startTime" : @"",
                                  @"title" : @"title",
                                  @"details" : @"content",
                                  @"link" : @"link",
                                  @"keepHtmlTags" : @"convertToLineBreaks"};
    
    NSString *feedUrlString = @"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/general-info/daily-announcements/posts.xml";
    
    //initialize stores
    _dailyAnnStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeDailyAnns]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       sortNowToFuture:NO
                       owner:self];
    
    _dailyAnnTVC = [[HHSDailyAnnVC alloc] initWithStore:_dailyAnnStore];
    _dailyAnnTVC.owner = self;
    _dailyAnnTVC.pagerIndex = 3;
    [_dailyAnnTVC view];
    
}

-(void)setUpLunch
{
    //these are values that the parser will scan for
    NSDictionary *parserNames = @{@"entry" : @"",
                                  @"date" : @"start",
                                  @"startTime" : @"",
                                  @"title" : @"summary",
                                  @"link" : @"htmlLink",
                                  @"details" : @"description",
                                  @"keepHtmlTags" : @""};

    
    NSString *feedUrlString = @"https://www.googleapis.com/calendar/v3/calendars/holliston.k12.ma.us_c2d4uic3gbsg7r9vv9qo8a949g%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=AIzaSyBsDse7YteqjWWEJpvAzxt3ZVToXSfjTEY";
    
    //initialize stores
    _lunchStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeLunch]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       sortNowToFuture:(BOOL)YES
                       owner:self];
    
    _lunchTVC = [[HHSLunchVC alloc] initWithStore:_lunchStore];
    _lunchTVC.owner = self;
    _lunchTVC.pagerIndex = 5;
    [_lunchTVC view];
    
    
}

-(void)setUpHome
{
    //initialize stores
    _homeVC.schedulesStore = _schedulesStore;
    _homeVC.eventsStore = _eventsStore;
    _homeVC.newsStore = _newsStore;
    _homeVC.dailyAnnStore = _dailyAnnStore;
    _homeVC.lunchStore = _lunchStore;
    _homeVC.owner = self;
}

#pragma mark handle navigation

- (IBAction)goToHome:(id)sender
{
    [self jumpToPage:0];
    _currentView = nil;
    HHSHomeViewController *view = _homeVC;
    _homeVC.pagerIndex = 0;
    view.schedulesStore = _schedulesTVC.articleStore;
    view.newsStore = _newsTVC.articleStore;
    view.dailyAnnStore = _dailyAnnTVC.articleStore;
    view.eventsStore = _eventsTVC.articleStore;
    
    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSHomeViewController *tvc = (HHSHomeViewController *) nvcsv.topViewController;
        if(tvc != _homeVC) {
            self.splitViewController.delegate = view;
            HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
            HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
            view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
            self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
        }
        if (self.currentPopover) {
            [self.currentPopover dismissPopoverAnimated:YES];
        }
    }
    else {
        [self.navigationController pushViewController:view animated:YES];
    }
}

- (IBAction)goToSchedules:(id)sender
{
    [self jumpToPage:1];
}

- (IBAction)goToDailyAnns:(id)sender
{
    [self jumpToPage:3];
}

- (IBAction)goToNews:(id)sender
{
    [self jumpToPage:2];
}

- (IBAction)goToEvents:(id)sender
{
    [self jumpToPage:4];
}

- (IBAction)goToLunch:(id)sender
{
    [self jumpToPage:5];
}

-(void)jumpToPage:(int) index {
    self.pager = [[HHSMainPager alloc] init];
    self.pager.parent = self;
    self.pager.startingPage = index;
    
    [self.navigationController pushViewController:self.pager animated:YES];
}

-(void)pushView:(HHSTableViewController *)view
{
    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSTableViewController *tvc = (HHSTableViewController *) nvcsv.topViewController;
        if(tvc != _currentView) {
            self.splitViewController.delegate = view;
            HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
            HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
            view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
            self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
        }
        if (self.currentPopover) {
            [self.currentPopover dismissPopoverAnimated:YES];
        }
    }else {
        [self.navigationController pushViewController:view animated:YES];
    }

}

- (IBAction)refreshDataButtonPushed:(id)sender
{
    [self showWaitingWithText:@"Refreshing Data\nPlease Wait..." buttonText:nil];
    
    _schedulesDownloaded = NO;
    _eventsDownloaded = NO;
    _newsDownloaded = NO;
    _eventsDownloaded = NO;
    _lunchDownloaded = NO;
    
    [_schedulesTVC.articleStore getEventsFromFeed];
    [_newsTVC.articleStore getArticlesFromFeed];
    [_eventsTVC.articleStore getEventsFromFeed];
    [_dailyAnnTVC.articleStore getArticlesFromFeed];
    [_lunchTVC.articleStore getEventsFromFeed];
}

-(void)refreshStores
{
    [self refreshDataButtonPushed:nil];
}

-(void)refreshViews
{
    [self showWaitingWithText:@"Loading..." buttonText:nil];
    [_schedulesTVC reloadArticlesFromStore];
    [_eventsTVC reloadArticlesFromStore];
    [_newsTVC reloadArticlesFromStore];
    [_dailyAnnTVC reloadArticlesFromStore];
    [_lunchTVC reloadArticlesFromStore];
    [_homeVC fillAll];
}

- (IBAction)goToWebsite:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://hhs.holliston.k12.ma.us"];
    [[UIApplication sharedApplication] openURL:url];
}



#pragma mark handle notifications

-(void)notifyStoreIsReady:(HHSArticleStore *)store
{
    if (store == _schedulesStore) {
        [_schedulesTVC reloadArticlesFromStore];
        [_homeVC fillSchedule];
        _schedulesDownloaded = YES;
    } else if (store == _newsStore) {
        [_newsTVC reloadArticlesFromStore];
        [_homeVC fillNews];
        _newsDownloaded =YES;
    } else if (store == _eventsStore) {
        [_eventsTVC reloadArticlesFromStore];
        [_homeVC fillEvents];
        _eventsDownloaded = YES;
    } else if (store == _dailyAnnStore) {
        [_dailyAnnTVC reloadArticlesFromStore];
        [_homeVC fillDailyAnn];
        _dailyAnnDownloaded = YES;
    } else if (store == _lunchStore) {
        [_lunchTVC reloadArticlesFromStore];
        //[_homeVC fillLunch];
        _lunchDownloaded = YES;
    }
    
    if (_schedulesDownloaded && _eventsDownloaded && _newsDownloaded && _dailyAnnDownloaded && _lunchDownloaded) {
        //[self performSelectorOnMainThread:@selector(hideWaiting) withObject:nil waitUntilDone:NO];
        [self hideWaiting];
    }
}

-(void)notifyStoreDownloadError:(HHSArticleStore *)store error:(NSString *)errorMessage
{
    [self showWaitingWithText:errorMessage buttonText:@"Ok"];
    /*if (store == _schedulesStore) {
        [_schedulesTVC downloadError];
        [_homeVC downloadError];
    } else if (store == _newsStore) {
        [_newsTVC downloadError];
        [_homeVC downloadError];
    } else if (store == _eventsStore) {
        [_eventsTVC downloadError];
        [_homeVC downloadError];
    } else if (store == _dailyAnnStore) {
        [_dailyAnnTVC downloadError];
        [_homeVC downloadError];
    }*/
}

-(void)setCurrentPopoverController:(UIPopoverController *)poc
{
    self.currentPopover = poc;
}

-(void)showWaitingWithText:(NSString *)text buttonText:(NSString *)buttonText
{
    [_alert dismissWithClickedButtonIndex:0 animated:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:buttonText otherButtonTitles: nil];
    [alert show];
    _alert = alert;
    
}

-(void)hideWaiting
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];

}

- (void) refreshDone:(int)type {
    
    switch (type) {
        case 1:
            _schedulesDownloaded = YES;
            break;
        case 2:
            _eventsDownloaded = YES;
            break;
        case 3:
            _newsDownloaded = YES;
            break;
        case 4:
            _dailyAnnDownloaded = YES;
            break;
        case 5:
            _lunchDownloaded = YES;
            break;
    }
    
    NSLog (@"%@",[NSString stringWithFormat:@"%@%i",
                  @"refreshDone complete for ArticleStore #", type]);
    
    if (_schedulesDownloaded && _eventsDownloaded && _newsDownloaded && _dailyAnnDownloaded && _lunchDownloaded) {
        [self performSelectorOnMainThread:@selector(hideWaiting) withObject:nil waitUntilDone:YES];
        //[self hideWaiting];
    }
}

//for BackgroundFetch

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"Background Fetch in HHSNavViewController activated");

    //[self refreshDataButtonPushed:nil];
    [_schedulesTVC.articleStore getEventsInBackground];
    [_newsTVC.articleStore getArticlesInBackground];
    [_eventsTVC.articleStore getEventsInBackground];
    [_dailyAnnTVC.articleStore getArticlesInBackground];
    [_lunchTVC.articleStore getEventsInBackground];
    //NSLog(@"4 requests for getArticlesInBackground sent to the article stores");

    NSLog(@"Background Fetch completed");

    completionHandler(UIBackgroundFetchResultNewData);

}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    int index;
    UIViewController *returnVC = [UIViewController alloc];
    
    if ([viewController isKindOfClass:[HHSHomeViewController class]]) {
        index = 0;
    } else {
        index = [(HHSTableViewController *)viewController pagerIndex];
    }
    
    index++;
    if (index >5) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    int index;
    UIViewController *returnVC = [[UIViewController alloc] init];
    
    if ([viewController isKindOfClass:[HHSHomeViewController class]]) {
        index = 0;
    } else {
        index = [(HHSTableViewController *)viewController pagerIndex];
    }
    
    index--;
    if (index <0) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}

-(UIViewController *)viewControllerAtIndex:(int)index {
    
    
    UIViewController *tvc = _homeVC;
    switch (index) {
        case 0:
            tvc = self.homeVC;
            break;
        case 1:
            tvc = self.schedulesTVC;
            break;
        case 2:
            tvc = self.newsTVC;
            break;
        case 3:
            tvc = self.dailyAnnTVC;
            break;
        case 4:
            tvc = self.eventsTVC;
            break;
        case 5:
            tvc = self.lunchTVC;
            break;
    }
    
    return tvc;
}





@end
