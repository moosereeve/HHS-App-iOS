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

@interface HHSTableViewController ()
// queue that manages our NSOperation for parsing article data
@property (nonatomic) NSOperationQueue *parseQueue;

@property (nonatomic, strong)NSString *mAddArticlesNotificationName;
@property (nonatomic, strong)NSString *mArticleResultsKey;
@property (nonatomic, strong)NSString *mArticlesErrorNotificationName;
@property (nonatomic, strong)NSString *mArticlesMessageErrorKey;

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
    
    [self updateTableViewForDynamicTypeSize];
    
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


-(void)getArticlesFromFeed
{
    
    _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self.articleStore getType]];
    _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self.articleStore getType]];

    _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self.articleStore getType]];

    _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self.articleStore getType]];

    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    
    NSURL *urlFeed = [[NSURL alloc] initWithString:self.feedUrlString];
    NSURLRequest *articleURLRequest =
    [NSURLRequest requestWithURL:urlFeed];
    
    // send the async request (note that the completion block will be called on the main thread)
    //
    // note: using the block-based "sendAsynchronousRequest" is preferred, and useful for
    // small data transfers that are likely to succeed. If you doing large data transfers,
    // consider using the NSURLConnectionDelegate-based APIs.
    //
    [NSURLConnection sendAsynchronousRequest:articleURLRequest
     // the NSOperationQueue upon which the handler block will be dispatched:
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               // back on the main thread, check for errors, if no errors start the parsing
                               //
                               [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                               
                               // here we check for any returned NSError from the server, "and" we also check for any http response errors
                               if (error != nil) {
                                   [self handleError:error];
                               }
                               else {
                                   // check for any response errors
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                   if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
                                       
                                       // Update the UI and start parsing the data,
                                       // Spawn an NSOperation to parse the earthquake data so that the UI is not
                                       // blocked while the application parses the XML data.
                                       //
                                       APLParseOperation *parseOperation = [[APLParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self.articleStore];
                                       [self.parseQueue addOperation:parseOperation];
                                   }
                                   else {
                                       NSString *errorString =
                                       NSLocalizedString(@"HTTP Error", @"Error message displayed when receving a connection error.");
                                       NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
                                       NSError *reportError = [NSError errorWithDomain:@"HTTP"
                                                                                  code:[httpResponse statusCode]
                                                                              userInfo:userInfo];
                                       [self handleError:reportError];
                                   }
                               }
                           }];
    
    // Start the status bar network activity indicator.
    // We'll turn it off when the connection finishes or experiences an error.
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addArticles:)
                                                 name:_mAddArticlesNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
    
    // if the locale changes behind our back, we need to be notified so we can update the date
    // format in the table view cells
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
}

#pragma mark network and xml
- (void)dealloc {
    
    // we are no longer interested in these notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:_mAddArticlesNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:_mArticlesErrorNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

/**
 Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
 */
- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
}

/**
 Our NSNotification callback from the running NSOperation to add the earthquakes
 */
- (void)addArticles:(NSNotification *)notif {
    
    assert([NSThread isMainThread]);
    [self addArticlesToList:[[notif userInfo] valueForKey:_mArticleResultsKey]];
    [_activityView stopAnimating];
}

/**
 Our NSNotification callback from the running NSOperation when a parsing error has occurred
 */
- (void)articlesError:(NSNotification *)notif {
    
    assert([NSThread isMainThread]);
    [self handleError:[[notif userInfo] valueForKey:_mArticlesMessageErrorKey]];
}

- (void)addArticlesToList:(NSArray *)articles {
    
    //each subclass must have its own version of this method
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



@end