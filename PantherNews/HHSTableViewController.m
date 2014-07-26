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
// queue that manages our NSOperation for parsing article data
@end

@implementation HHSTableViewController
@synthesize popoverController;
@synthesize delegate;

- (id)init{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
        self.sectionGroups = [[NSMutableArray array] init];
        
        self.articlesList = [[NSMutableArray array] init];
        self.clearsSelectionOnViewWillAppear = YES;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(updateTableViewForDynamicTypeSize)
                   name:UIContentSizeCategoryDidChangeNotification object:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    if([self.articles count] ==0) {
        
        _activityView.center=self.view.center;
    
        [_activityView startAnimating];
    
        [self.view addSubview:_activityView];
        
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}

- (void)updateTableViewForDynamicTypeSize
{
    static NSDictionary *cellHeightDictionary;
    
    if (!cellHeightDictionary) {
        cellHeightDictionary = @{ UIContentSizeCategoryExtraSmall: @44,
                                  UIContentSizeCategorySmall: @44,
                                  UIContentSizeCategoryMedium: @44,
                                  UIContentSizeCategoryLarge: @44,
                                  UIContentSizeCategoryExtraLarge: @55,
                                  UIContentSizeCategoryExtraLarge: @65,
                                  UIContentSizeCategoryExtraExtraExtraLarge: @75};
        
    }
    NSString *userSize = [[UIApplication sharedApplication] preferredContentSizeCategory];
    NSNumber *cellHeight = cellHeightDictionary[userSize];
    [self.tableView setRowHeight:cellHeight.floatValue];
    [self.tableView reloadData];
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
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    self.popoverController = nil;
}

-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    
    barButtonItem.title = @"<< Main Menu";
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
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

- (void)retrieveArticles {
    //to be overridden
}



@end