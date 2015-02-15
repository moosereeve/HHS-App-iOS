//
//  HHSTableViewController.m
//  
//
//  Created by Thomas Reeve on 6/23/14.
//
//

#import "HHSTableViewController.h"
#import "HHSArticleStore.h"
#import "APLParseOperation.h"
#import "HHSNavViewController.h"
#import "HHSHomeViewController.h"

@interface HHSTableViewController ()
@end

@implementation HHSTableViewController
@synthesize popoverController;

-(id)init
{
    self = [super init];
    NSLog(@"Wrong initializer. Use InitWithStore");
    return self;
}

- (id)initWithStore:(HHSArticleStore *) store
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.articleStore = store;
        
        self.sectionGroups = [[NSMutableArray array] init];
        
        self.articlesList = [[NSMutableArray array] init];
        self.clearsSelectionOnViewWillAppear = YES;
        
        _viewLoaded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    if(([self.articlesList count] == 0)) {
        [self.owner showWaitingWithText:@"Loading..." buttonText:nil];
    }
    
    _viewLoaded = YES;
    
}

-(void)downloadError
{
    [self.owner hideWaiting];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
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
    
    if (barButtonItem != self.navigationItem.leftBarButtonItem) {
        barButtonItem.title = @"<< Main Menu";
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    self.popoverController = pc;
    UINavigationController *nvc = svc.viewControllers[0];
    HHSNavViewController *hhsnvc = nvc.viewControllers[0];
    [hhsnvc setCurrentPopoverController:pc];
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    self.popoverController = pc;
    UINavigationController *nvc = svc.viewControllers[0];
    HHSNavViewController *hhsnvc = nvc.viewControllers[0];
    [hhsnvc setCurrentPopoverController:pc];

}


- (void)navigationControllerSelectedItem:(id)item {
    // If a popover controller is visible, hide it
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void)reloadArticlesFromStore {
    //to be overridden
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

-(UIViewController *)viewControllerAtIndex:(int)index {
    
    return nil;
}


@end