//
//  HHSNavViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSNavViewController.h"
#import "HHSHomeViewController.h"
#import "HHSScheduleTableViewController.h"
#import "HHSDailyAnnTableViewController.h"
#import "HHSEventsTableViewController.h"
#import "HHSNewsTableViewController.h"
#import "HHSArticleStore.h"
#import "APLParseOperation.h"
#import "HHSNavigationControllerForSplitView.h"

@interface HHSNavViewController ()
@property (nonatomic, strong) UIPopoverController *currentPopover;
@property (nonatomic, strong) UIAlertView *alert;

@end

@implementation HHSNavViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"NavViewController init started");
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Holliston High School";
        
        [[UINavigationBar appearance] setTitleTextAttributes: @{
                NSForegroundColorAttributeName: [UIColor whiteColor],
                
                }];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed: (181/255.0) green:(30/255.0) blue:(18/255.0) alpha:(255/255.0)]];
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithTitle: @"Menu"
                                       style: UIBarButtonItemStyleBordered
                                      target: nil action: nil];
        
        [self.navigationItem setBackBarButtonItem: backButton];

        _homeVC = [[HHSHomeViewController alloc] init];
        [self setUpSchedules];
        [self setUpNews];
        [self setUpEvents];
        [self setUpDailyAnn];
        [self setUpHome];
        [self refreshDataButtonPushed:nil];
        
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self goToHome:nil];
}

-(void)setUpSchedules
{
    _schedulesTVC = [[HHSScheduleTableViewController alloc] init];
    //these are values that the parser will scan for
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"gd:when",
                                  @"startTime" : @"startTime",
                                  @"title" : @"title",
                                  @"link" : @"link",
                                  @"details" : @"content",
                                  @"keepHtmlTags" : @"skip"};
    
    NSString *feedUrlString = @"http://www.google.com/calendar/feeds/sulsp2f8e4npqtmdp469o8tmro%40group.calendar.google.com/private-fe49e26b4b5bd4579c74fd9c94e2d445/full?orderby=starttime&sortorder=a&futureevents=true&singleevents=true&ctz=America/New_York";

    NSArray *schedulesOwners = @[_schedulesTVC, _homeVC];
    
    //initialize stores
    _schedulesStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeSchedules]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       owners:(NSArray *)schedulesOwners];
    
    _schedulesTVC.articleStore = _schedulesStore;
    _schedulesTVC.delegate = (HHSTableViewController *) self;
    //[_schedulesTVC retrieveArticles];
    
}

-(void)setUpEvents
{
    _eventsTVC = [[HHSEventsTableViewController alloc] init];
    //these are values that the parser will scan for
    
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"gd:when",
                                  @"startTime" : @"startTime",
                                  @"title" : @"title",
                                  @"link" : @"link",
                                  @"details" : @"content",
                                  @"keepHtmlTags" : @"skip"};
    
    NSString *feedUrlString = @"https://www.google.com/calendar/feeds/holliston.k12.ma.us_gsfpbqnefkm59ul6gbofte1s2k%40group.calendar.google.com/private-641b39b01a46e77af57592990d225fac/full?orderby=starttime&sortorder=a&futureevents=true&singleevents=true&ctz=America/New_York";

    
    NSArray *owners = @[_eventsTVC, _homeVC];
    
    //initialize stores
    _eventsStore = [[HHSArticleStore alloc]
                      initWithType:[HHSArticleStore HHSArticleStoreTypeEvents]
                      parserNames:parserNames
                      feedUrlString:feedUrlString
                      owners:(NSArray *)owners];
    
    _eventsTVC.articleStore = _eventsStore;
    _eventsTVC.delegate = (HHSTableViewController *) self;
    //[_eventsTVC retrieveArticles];
}

-(void)setUpNews
{
    _newsTVC = [[HHSNewsTableViewController alloc] init];
    //these are values that the parser will scan for
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"updated",
                                  @"startTime" : @"",
                                  @"title" : @"title",
                                  @"link" : @"link",
                                  @"details" : @"content",
                                  @"keepHtmlTags" : @"keep"};
    
    NSString *feedUrlString = @"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/general-info/news/posts.xml";
    
    NSArray *owners = @[_newsTVC, _homeVC];
    
    //initialize stores
    _newsStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeNews]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       owners:(NSArray *)owners];
    
    _newsTVC.articleStore = _newsStore;
    _newsTVC.delegate = (HHSTableViewController *) self;
    //[_newsTVC retrieveArticles];
}
-(void)setUpDailyAnn
{
    _dailyAnnTVC = [[HHSDailyAnnTableViewController alloc] init];
    //these are values that the parser will scan for
    
    NSDictionary *parserNames = @{@"entry" : @"entry",
                                  @"date" : @"published",
                                  @"startTime" : @"",
                                  @"title" : @"title",
                                  @"details" : @"content",
                                  @"link" : @"link",
                                  @"keepHtmlTags" : @"convertToLineBreaks"};
    
    NSString *feedUrlString = @"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/general-info/daily-announcements/posts.xml";
    
    NSArray *owners = @[_dailyAnnTVC, _homeVC];
    
    //initialize stores
    _dailyAnnStore = [[HHSArticleStore alloc]
                       initWithType:[HHSArticleStore HHSArticleStoreTypeDailyAnns]
                       parserNames:parserNames
                       feedUrlString:feedUrlString
                       owners:(NSArray *)owners];
    
    _dailyAnnTVC.articleStore = _dailyAnnStore;
    _dailyAnnTVC.delegate = (HHSTableViewController *) self;
    //[_dailyAnnTVC retrieveArticles];
}
-(void)setUpHome
{
    //initialize stores
    _homeVC.schedulesStore = _schedulesStore;
    _homeVC.eventsStore = _eventsStore;
    _homeVC.newsStore = _newsStore;
    _homeVC.dailyAnnStore = _dailyAnnStore;
    _homeVC.delegate = (HHSTableViewController *) self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToHome:(id)sender
{
    HHSHomeViewController *view = _homeVC;
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
    HHSScheduleTableViewController *view = _schedulesTVC;
    self.tableViewController = view;
    
    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSTableViewController *tvc = (HHSTableViewController *) nvcsv.topViewController;
        if(tvc != _schedulesTVC) {
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

- (IBAction)goToDailyAnns:(id)sender
{
    HHSDailyAnnTableViewController *view = _dailyAnnTVC;
    self.tableViewController = view;

    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSTableViewController *tvc = (HHSTableViewController *) nvcsv.topViewController;
        if(tvc != _dailyAnnTVC) {
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

- (IBAction)goToNews:(id)sender
{
    HHSNewsTableViewController *view = _newsTVC;
    self.tableViewController = view;
    
    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSTableViewController *tvc = (HHSTableViewController *) nvcsv.topViewController;
        if(tvc != _newsTVC) {
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

- (IBAction)goToEvents:(id)sender
{
    HHSEventsTableViewController *view = _eventsTVC;
    self.tableViewController = view;
    
    if( self.splitViewController) {
        // prevent redisplaying if already displaying
        //( this is needed to prevent breaking the back button, although I don't know why)
        HHSNavigationControllerForSplitView *nvcsv = (HHSNavigationControllerForSplitView *) self.splitViewController.viewControllers[1];
        HHSTableViewController *tvc = (HHSTableViewController *) nvcsv.topViewController;
        if(tvc != _eventsTVC) {
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

- (IBAction)goToWebsite:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"https://sites.google.com/a/holliston.k12.ma.us/holliston-high-school/"];
    [[UIApplication sharedApplication] openURL:url];
}

-(void)setCurrentPopoverController:(UIPopoverController *)poc
{
    self.currentPopover = poc;
}

-(void)showWaitingWithText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    
    UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 50, 30, 30)];
    progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [alert addSubview:progress];
    [progress startAnimating];
    [alert show];
    
    _alert = alert;
    
}

-(void)hideWaiting
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];

}

- (IBAction)refreshDataButtonPushed:(id)sender
{
    [self showWaitingWithText:@"Refreshing Data\nPlease Wait..."];
    
    _schedulesDownloaded = NO;
    _eventsDownloaded = NO;
    _newsDownloaded = NO;
    _eventsDownloaded = NO;
    
    [_schedulesTVC.articleStore getArticlesFromFeed];
    [_newsTVC.articleStore getArticlesFromFeed];
    [_eventsTVC.articleStore getArticlesFromFeed];
    [_dailyAnnTVC.articleStore getArticlesFromFeed];
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
            _dailAynnDownloaded = YES;
            break;
    }
    
    NSLog (@"%@",[NSString stringWithFormat:@"%@%i",
                  @"refreshDone complete for ArticleStore #", type]);
    
    if (_schedulesDownloaded && _eventsDownloaded && _newsDownloaded && _dailAynnDownloaded) {
        [self hideWaiting];
        HHSHomeViewController *maybeHome = (HHSHomeViewController *) self.tableViewController;
        if (maybeHome == _homeVC) {
            [_homeVC fillAll];
        }
    }
}

//for BackgroundFetch

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"Background Fetch in HHSNavViewController activated");

    [self refreshDataButtonPushed:nil];
    //[_schedulesTVC.articleStore getArticlesFromFeed];
    //[_newsTVC.articleStore getArticlesFromFeed];
    //[_eventsTVC.articleStore getArticlesFromFeed];
    //[_dailyAnnTVC.articleStore getArticlesFromFeed];
    NSLog(@"4 requests for getArticlesFrom Feed sent to the article stores");

    NSLog(@"Background Fetch completed");

    completionHandler(UIBackgroundFetchResultNewData);

}


@end
