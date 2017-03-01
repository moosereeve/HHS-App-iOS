//
//  HHSCategoryVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSCategoryVC.h"
#import "HHSArticleStore.h"
#import "HHSXmlParseOperation.h"
#import "HHSMainViewController.h"
#import "HHSHomeViewController.h"
#import "HHSDetailPager.h"

@interface HHSCategoryVC ()

@end

@implementation HHSCategoryVC
@synthesize popoverController;

-(id)init
{
    self = [super init];
    NSLog(@"Wrong initializer. Use InitWithStore");
    return self;
}

- (id)initWithStore:(HHSArticleStore *) store
{
    self = [super init];//[super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.articleStore = store;
        
        self.sectionGroups = [[NSMutableArray array] init];
        
        self.articlesList = [[NSMutableArray array] init];
        
        _isViewLoaded  = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    /*if(([self.articlesList count] == 0)) {
        [self.owner showWaitingWithText:@"Loading..." buttonText:nil];
    }*/
    
    _isViewLoaded = YES;
    
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshStores) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

-(void)downloadError
{
    [self.owner hideWaiting];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

#pragma mark tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

#pragma mark - Locale changes

- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    if (barButtonItem == self.navigationItem.leftBarButtonItem) {
        //self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.popoverController = nil;
}

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    /*if (barButtonItem != self.navigationItem.leftBarButtonItem) {
        barButtonItem.title = @"<< Main Menu";
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    self.popoverController = pc;
    UINavigationController *nvc = svc.viewControllers[0];
    HHSMainViewController *hhsnvc = nvc.viewControllers[0];
    [hhsnvc setCurrentPopoverController:pc];
     */
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    /*self.popoverController = pc;
    UINavigationController *nvc = svc.viewControllers[0];
    HHSMainViewController *hhsnvc = nvc.viewControllers[0];
    [hhsnvc setCurrentPopoverController:pc];
     */
    
}


- (void)navigationControllerSelectedItem:(id)item {
    // If a popover controller is visible, hide it
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)reloadArticlesFromStore {
    //to be overridden
    if (self.articleStore.downloadError) {
        [self.owner hideWaiting];
        return;
    } else {
        [self.refreshControl endRefreshing];
    }
}

/*-(void)setCurrentPopoverController:(UIPopoverController *)poc
 {
 //to be overridden
 }
 
 -(void)refreshDone:(int)type
 {
 NSLog (@"%@",[NSString stringWithFormat:@"%@%i",
 @"refreshDone complete for ArticleStore #",
 [self.articleStore getType]]);
 //to be overridden
 }*/

-(void)refreshStores {
    [self.owner refreshStores];
}

-(UIViewController *)viewControllerAtIndex:(int)index {
    
    return nil;
}

-(void)sendToDetailPager:(int)index parentViewController:(HHSCategoryVC *)viewController {
    
    HHSDetailPager *pager = [[HHSDetailPager alloc] init];
    if(viewController == nil) {
        viewController = self;
    }
    pager.articleStore = viewController.articleStore;
    pager.parent = viewController;;
    pager.startingArticleIndex = index;
    
    if (self.parentViewController.splitViewController == nil) {
        [self.navigationController pushViewController:pager animated:YES];
    } else {
        [self.navigationController.splitViewController setViewControllers:@[self.owner.swViewController, pager]];
    }
}





@end
