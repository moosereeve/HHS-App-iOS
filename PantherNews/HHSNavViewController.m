//
//  HHSNavViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSNavViewController.h"
#import "HHSScheduleTableViewController.h"
#import "HHSDailyAnnTableViewController.h"
#import "HHSEventsTableViewController.h"
#import "HHSNewsTableViewController.h"
#import "HHSArticleStore.h"
#import "APLParseOperation.h"
#import "HHSNavigationControllerForSplitView.h"

@interface HHSNavViewController ()
@property (nonatomic, strong) HHSScheduleTableViewController *schedulesTVC;
@property (nonatomic, strong) HHSEventsTableViewController *eventsTVC;
@property (nonatomic, strong) HHSNewsTableViewController *newsTVC;
@property (nonatomic, strong) HHSDailyAnnTableViewController *dailyAnnTVC;

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
        
        //initialize tableViewControllers
        _schedulesTVC = [[HHSScheduleTableViewController alloc] init];
        _eventsTVC = [[HHSEventsTableViewController alloc] init];
        _newsTVC = [[HHSNewsTableViewController alloc] init];
        _dailyAnnTVC = [[HHSDailyAnnTableViewController alloc] init];
        
        _schedulesTVC.delegate = self;
        _eventsTVC.delegate = self;
        _newsTVC.delegate = self;
        _dailyAnnTVC.delegate = self;
        
        self.splitViewController.delegate = _schedulesTVC;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToSchedules:(id)sender
{
    
    HHSScheduleTableViewController *view = _schedulesTVC;
    self.tableViewController = view;
    if( self.splitViewController) {
        self.splitViewController.delegate = view;
        HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
        HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
        view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
        self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
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
        self.splitViewController.delegate = view;
        HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
        HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
        view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
        self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
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
        self.splitViewController.delegate = view;
        HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
        HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
        view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
        self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
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
        self.splitViewController.delegate = view;
        HHSNavigationControllerForSplitView *masternav = [self.splitViewController.viewControllers objectAtIndex:0];
        HHSNavigationControllerForSplitView *detailNav = [[HHSNavigationControllerForSplitView alloc] initWithRootViewController:view];
        view.navigationItem.leftBarButtonItem = [[[[self.splitViewController.viewControllers objectAtIndex:1]topViewController]navigationItem ]leftBarButtonItem];  //With this you tet a pointer to the button from the first detail VC but from the new detail VC
        self.splitViewController.viewControllers = @[masternav,detailNav];  //Now you set the new detail VC as the only VC in the array of VCs of the subclassed navigation controller which is the right VC of the split view Controller
        if (self.currentPopover) {
            [self.currentPopover dismissPopoverAnimated:YES];
        }
    }
    else {
        [self.navigationController pushViewController:view animated:YES];
    }

}

-(void)setCurrentPopoverController:(UIPopoverController *)poc
{
    self.currentPopover = poc;
}

- (IBAction)refreshDataButtonPushed:(id)sender
{
    _alert = [[UIAlertView alloc] initWithTitle:@"Downloading Data\nPlease Wait..." message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [_alert show];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Adjust the indicator so it is up a few pixels from the bottom of the alert
    indicator.center = CGPointMake(_alert.bounds.size.width / 2, _alert.bounds.size.height - 50);
    [indicator startAnimating];
    [_alert addSubview:indicator];
    
    _schedulesDownloaded = NO;
    _eventsDownloaded = NO;
    _newsDownloaded = NO;
    _eventsDownloaded = NO;
    
    [_schedulesTVC getArticlesFromFeed];
    [_newsTVC getArticlesFromFeed];
    [_eventsTVC getArticlesFromFeed];
    [_dailyAnnTVC getArticlesFromFeed];

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
    
    if (_schedulesDownloaded && _eventsDownloaded && _newsDownloaded && _dailAynnDownloaded) {
        
        [_alert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

//for BackgroundFetch

-(void)fetchNewDataWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"Background Fetch activated");

    [_schedulesTVC getArticlesFromFeed];
    [_newsTVC getArticlesFromFeed];
    [_eventsTVC getArticlesFromFeed];
    [_dailyAnnTVC getArticlesFromFeed];
    
    NSLog(@"Background Fetch completed");

    completionHandler(UIBackgroundFetchResultNewData);

}


@end
