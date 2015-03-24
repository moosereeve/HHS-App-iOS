//
//  HHSMainViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSMainViewController.h"
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
#import "HHSDetailPager.h"
#import "SWRevealViewController.h"
#import "HHSSocialViewController.h"
#import "HHSAboutViewController.h"

@interface HHSMainViewController ()
@property (nonatomic, strong) HHSMainPager *pager;
@property (nonatomic) int currentPagerIndex;
@property (nonatomic, strong) NSArray *pagerViewControllers;
@property (nonatomic, strong) UIPopoverController *currentPopover;
@property (nonatomic, strong) UIAlertView *alert;
@property BOOL errorShowing;
@property (nonatomic, strong) NSString *apiKey;

@end

@implementation HHSMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"NavViewController init started");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist" ]];
        self.apiKey = [dictionary objectForKey:@"apiKey"];
        
        
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
    
    self.swViewController = [self revealViewController];
    [self.swViewController panGestureRecognizer];
    [self.swViewController tapGestureRecognizer];
    
    UINavigationItem *navItem = self.navigationItem;
    navItem.title = @"Holliston High School";
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName: [UIColor whiteColor],}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed: (181/255.0) green:(30/255.0) blue:(18/255.0) alpha:(128/255.0)]];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed: (181/255.0) green:(30/255.0) blue:(18/255.0) alpha:(128/255.0)];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    //UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    //[backButton setTintColor:[UIColor whiteColor]];
    
    //[self.navigationItem setBackBarButtonItem: backButton];
    //self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],};
    
    self.pager = [[HHSMainPager alloc] init];
    self.pager.parent = self;
    
    [self addChildViewController: self.pager];
    [self.view addSubview:self.pager.view];
    [self.pager didMoveToParentViewController:self];
    
    
    
    UIImage *hamburger = [[UIImage imageNamed:@"hamburger"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setImage:hamburger forState:UIControlStateNormal];
    [menuButton addTarget:self.swViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setFrame:CGRectMake(0, 0, 53, 31)];
    
    UIBarButtonItem *revealBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    self.navigationItem.leftBarButtonItem = revealBarButtonItem;
    
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
    
    NSString *feedUrlString = [NSString stringWithFormat:@"%@%@", @"https://www.googleapis.com/calendar/v3/calendars/sulsp2f8e4npqtmdp469o8tmro%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=", self.apiKey];
    
    //initialize stores
    _schedulesStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeSchedules]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       sortNowToFuture:YES
                       triggersNotification:NO
                       owner:self];
    
    _schedulesTVC = [[HHSSchedulesVC alloc] initWithStore:_schedulesStore];
    _schedulesTVC.title = @"SchedulesVC";
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
    
    
    NSString *feedUrlString = [NSString stringWithFormat:@"%@%@", @"https://www.googleapis.com/calendar/v3/calendars/holliston.k12.ma.us_gsfpbqnefkm59ul6gbofte1s2k%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=", self.apiKey];
    
    //initialize stores
    _eventsStore = [[HHSArticleStore alloc]
                    initWithType:[HHSArticleStore HHSArticleStoreTypeEvents]
                    parserNames:parserNames
                    feedUrlString:feedUrlString
                    sortNowToFuture:YES
                    triggersNotification:NO
                    owner:self];
    
    _eventsTVC = [[HHSEventsVC alloc] initWithStore:_eventsStore];
    _eventsTVC.owner = self;
    _eventsTVC.title = @"EventsVC";
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
                  triggersNotification:YES
                  owner:self];
    
    _newsTVC = [[HHSNewsVC alloc] initWithStore:_newsStore];
    _newsTVC.title = @"NewsVC";
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
                      triggersNotification:NO
                      owner:self];
    
    _dailyAnnTVC = [[HHSDailyAnnVC alloc] initWithStore:_dailyAnnStore];
    _dailyAnnTVC.title = @"DailyAnnVC";
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
    
    
    NSString *feedUrlString =  [NSString stringWithFormat:@"%@%@", @"https://www.googleapis.com/calendar/v3/calendars/holliston.k12.ma.us_c2d4uic3gbsg7r9vv9qo8a949g%40group.calendar.google.com/events?maxResults=30&orderBy=startTime&singleEvents=true&key=", self.apiKey];
    
    //initialize stores
    _lunchStore = [[HHSArticleStore alloc]
                   initWithType:[HHSArticleStore HHSArticleStoreTypeLunch]
                   parserNames:parserNames
                   feedUrlString:feedUrlString
                   sortNowToFuture:(BOOL)YES
                   triggersNotification:NO
                   owner:self];
    
    _lunchTVC = [[HHSLunchVC alloc] initWithStore:_lunchStore];
    _lunchTVC.title = @"LunchVC";
    _lunchTVC.owner = self;
    _lunchTVC.pagerIndex = 5;
    [_lunchTVC view];
    
    
}

-(void)setUpHome
{
    self.homeVC = [[HHSHomeViewController alloc] init];
    self.homeVC.title = @"HomeVC";
    //initialize stores
    _homeVC.title = @"HomeVC";
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
    
    _currentView = nil;
    HHSHomeViewController *view = _homeVC;
    _homeVC.pagerIndex = 0;
    view.schedulesStore = _schedulesTVC.articleStore;
    view.newsStore = _newsTVC.articleStore;
    view.dailyAnnStore = _dailyAnnTVC.articleStore;
    view.eventsStore = _eventsTVC.articleStore;
    
    if(self.splitViewController) {
        HHSDetailPager *detailPager = [[HHSDetailPager alloc] init];
        detailPager.articleStore = _schedulesStore;
        detailPager.parent = _schedulesTVC;
        detailPager.startingArticleIndex = 0;

        self.splitViewController.viewControllers = @[view, detailPager];
        if (self.currentPopover) {
            [self.currentPopover dismissPopoverAnimated:YES];
        }
    }
    else {
        [self jumpToPage:0];
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

- (void)refreshDataButtonPushed
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
    //[self refreshDataButtonPushed];
    [_homeVC beginRefreshingView];
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

-(void)jumpToPage:(int) index {
    
    int currentIndex = self.currentPagerIndex;
    self.currentPagerIndex = index;
    
    if (index > currentIndex) {
        for (int i = currentIndex; i<=index; i++) {
            self.currentPagerIndex = i;
            [self.pager.pageController setViewControllers:@[[self viewControllerAtIndex:i]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        }
        
    } else if (index < currentIndex) {
        for (int i = currentIndex; i>=index; i--) {
            self.currentPagerIndex = i;
            [self.pager.pageController setViewControllers:@[[self viewControllerAtIndex:i]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
        }
    }
    
    [self presentationIndexForPageViewController:(UIPageViewController*)self.pager];
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    int index;
    UIViewController *returnVC = [UIViewController alloc];
    
    if ([viewController isKindOfClass:[HHSHomeViewController class]]) {
        index = 0;
    } else {
        index = [(HHSCategoryVC *)viewController pagerIndex];
    }
    
    index++;
    if (index >7) {
        index = 0;
    }
    
    returnVC =[self viewControllerAtIndex:index];
    self.currentPagerIndex = index;
    
    
    return returnVC;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    int index;
    UIViewController *returnVC = [[UIViewController alloc] init];
    
    if ([viewController isKindOfClass:[HHSHomeViewController class]]) {
        index = 0;
    } else {
        index = [(HHSCategoryVC *)viewController pagerIndex];
    }
    
    index--;
    if (index <0) {
        index = 7;
    }
    
    returnVC =[self viewControllerAtIndex:index];
    self.currentPagerIndex = index;
    
    
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
        case 6:
            tvc = [[HHSSocialViewController alloc] init];
            break;
        case 7:
            tvc = [[HHSAboutViewController alloc] init];
            break;
    }
    
    return tvc;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 8;
}
-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return self.currentPagerIndex;
}







@end
