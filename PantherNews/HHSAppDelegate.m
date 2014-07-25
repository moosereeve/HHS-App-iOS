//
//  HHSAppDelegate.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSAppDelegate.h"
#import "HHSNavViewController.h"
#import "HHSHomeViewController.h"
#import "HHSArticleStore.h"

@interface HHSAppDelegate ()
@property (nonatomic, strong) UISplitViewController *splitvc;
@property (nonatomic, strong) HHSNavViewController *nvc;
@end

@implementation HHSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    _nvc = [[HHSNavViewController alloc] init];
    UINavigationController *masternav = [[UINavigationController alloc] initWithRootViewController:_nvc];
    
    //HHSScheduleTableViewController *stvc = [[HHSScheduleTableViewController alloc] init];
    //stvc.articleStore = [[HHSArticleStore alloc] initWithType:[HHSArticleStore HHSArticleStoreTypeSchedules]];
    
    //HHSTableViewController *tablevc;
    HHSHomeViewController *home = [[HHSHomeViewController alloc] init];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        UINavigationController *detailNav = [[UINavigationController alloc] initWithRootViewController:home];
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIInterfaceOrientationPortrait)
        { /*   UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
            barButton.title = @"<< Main Menu";
            stvc.navigationItem.leftBarButtonItem = barButton;
        */}
        
        _splitvc = [[UISplitViewController alloc] init];
        
        //set delegate of splitview to detail vc
        _splitvc.delegate = home;
        
        _splitvc.viewControllers = @[masternav, detailNav];
        
        self.window.rootViewController = _splitvc;
        
    }
    else {
        //on non-iPad devices, do normal screens
        self.window.rootViewController = masternav;
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSDate *fetchStart = [NSDate date];
    
    //HHSNavViewController *viewController = (HHSNavViewController *)self.window.rootViewController;
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    HHSNavViewController *viewController = (HHSNavViewController *)[[navController viewControllers] objectAtIndex:0];
    
    [viewController fetchNewDataWithCompletionHandler:^(UIBackgroundFetchResult result) {
        completionHandler(result);
        
        NSDate *fetchEnd = [NSDate date];
        NSTimeInterval timeElapsed = [fetchEnd timeIntervalSinceDate:fetchStart];
        NSLog(@"Background Fetch Duration: %f seconds", timeElapsed);
        
    }];
}


@end
