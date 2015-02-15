//
//  HHSAppDelegate.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSAppDelegate.h"
#import "HHSMainViewController.h"
#import "HHSHomeViewController.h"
#import "HHSArticleStore.h"
#import "HHSMenuController.h"
#import "HHSDetailPager.h"
#import "SWRevealViewController.h"

@interface HHSAppDelegate ()
@property (nonatomic, strong) UISplitViewController *splitvc;
@property (nonatomic, strong) HHSMainViewController *nvc;
@end

@implementation HHSAppDelegate

@synthesize window = _window;
@synthesize swViewController = _swViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.backgroundColor = [UIColor colorWithRed: (181/255.0) green:(30/255.0) blue:(18/255.0) alpha:(255/255.0)];
    
    _nvc = [[HHSMainViewController alloc] init];
    UIViewController *masternav = [[UINavigationController alloc] initWithRootViewController:_nvc];
    masternav.title = @"MasterNavController";
    
    //setup SWReveal menu system
    HHSMenuController *menuController = [[HHSMenuController alloc] init];
    menuController.mainViewController = _nvc;
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:menuController frontViewController:masternav];
    revealController.title = @"swRevealController";
    
    revealController.delegate = (id)self;
    self.swViewController = revealController;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)  {
        
        HHSDetailPager *detailPager = [[HHSDetailPager alloc] init];
        
        detailPager.articleStore = _nvc.schedulesStore;
        detailPager.parent = (HHSCategoryVC*)_nvc.schedulesTVC;
        detailPager.startingArticleIndex = 0;
       
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationPortrait)
        { /*   UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
            barButton.title = @"<< Main Menu";
            stvc.navigationItem.leftBarButtonItem = barButton;
        */}
        
        _splitvc = [[UISplitViewController alloc] init];
        _splitvc.delegate = _nvc.homeVC;
        _splitvc.viewControllers = @[self.swViewController, detailPager];//detailNav];
        
        self.window.rootViewController = _splitvc;
        
    }
    else {
        //on non-iPad devices, do normal screens
        self.window.rootViewController = self.swViewController;// masternav;
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL needsUpdating = [HHSArticleStore needsUpdating];
    if (needsUpdating) {
        [_nvc refreshStores];
    } else {
        [_nvc notifyStoreIsReady:_nvc.schedulesStore];
        [_nvc notifyStoreIsReady:_nvc.newsStore];
        [_nvc notifyStoreIsReady:_nvc.eventsStore];
        [_nvc notifyStoreIsReady:_nvc.dailyAnnStore];
    }
    
    NSLog(@"%@%@", @"Needs Updating? ", needsUpdating ? @"YES" : @"NO");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSDate *fetchStart = [NSDate date];
    
    //HHSNavViewController *viewController = (HHSNavViewController *)self.window.rootViewController;
    
    //UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    //HHSNavViewController *viewController = (HHSNavViewController *)[[navController viewControllers] objectAtIndex:0];
    
    [_nvc fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
        
    }];
}


@end
