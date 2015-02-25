//
//  HHSHomeViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 7/23/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSHomeViewController.h"
#import "HHSArticleStore.h"
#import "HHSArticle.h"
#import "APLParseOperation.h"
#import "HHSEventsCell.h"
#import "HHSImageStore.h"
#import "HHSCategoryVC.h"
#import "HHSScheduleDetailsViewController.h"
#import "HHSNewsDetailsViewController.h"
#import "HHSEventsDetailsViewController.h"
#import "HHSDailyAnnDetailsViewController.h"
#import "HHSLunchDetailsViewController.h"
#import "HHSNavViewController.h"
#import "HHSDetailPager.h"

@interface HHSHomeViewController ()
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSDictionary *images;

@property (nonatomic, weak) HHSArticle *scheduleArticle;
@property (nonatomic, weak) HHSArticle *newsArticle;
@property (nonatomic, weak) HHSArticle *dailyAnnArticle;
@property (nonatomic) NSMutableArray *eventsArticles;
@property (nonatomic, weak) HHSArticle *lunchArticle;

@property (nonatomic, strong) UITableView *eventsTable;
@property int eventsCellHeight;
@property int eventsHeaderHeight;

@property (nonatomic, strong)NSString *mAddArticlesNotificationName;
@property (nonatomic, strong)NSString *mArticleResultsKey;
@property (nonatomic, strong)NSString *mArticlesErrorNotificationName;
@property (nonatomic, strong)NSString *mArticlesMessageErrorKey;
@property (nonatomic, weak) NSLayoutConstraint *contentHeightConstraint;

@property (nonatomic) BOOL skipToday;

@end

@implementation HHSHomeViewController
@synthesize eventsTable;
@synthesize popoverController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Home";
        self.viewLoaded = NO;
        
        self.eventsHeaderHeight = 30;
        self.eventsCellHeight = 50;
        
        UIImage *a = [UIImage imageNamed:@"a_lg"];
        UIImage *b = [UIImage imageNamed:@"b_lg"];
        UIImage *c = [UIImage imageNamed:@"c_lg"];
        UIImage *d = [UIImage imageNamed:@"d_lg"];
        UIImage *star = [UIImage imageNamed:@"star_lg"];
        
        _images = @{@"a" : a,
                    @"b" : b,
                    @"c" : c,
                    @"d" : d,
                    @"star" : star };
        
        self.skipToday = NO;
        
        for (int i = 0; i<4; i++)
        {
            
        NSString *schedNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [HHSArticleStore HHSArticleStoreTypeSchedules]];
        NSString *eventsNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [HHSArticleStore HHSArticleStoreTypeEvents]];
        NSString *newsNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [HHSArticleStore HHSArticleStoreTypeNews]];
        NSString *dailyAnnNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [HHSArticleStore HHSArticleStoreTypeDailyAnns]];
        NSString *lunchNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [HHSArticleStore HHSArticleStoreTypeLunch]];
    
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fillSchedule)
                                                     name:schedNotificationName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fillEvents)
                                                     name:eventsNotificationName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fillNews)
                                                     name:newsNotificationName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fillDailyAnn)
                                                     name:dailyAnnNotificationName
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(fillLunch)
                                                    name:lunchNotificationName
                                                   object:nil];
    }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.eventsTable = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    //self.eventsTable.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.eventsTable.delegate = self;
    self.eventsTable.dataSource = (UITableViewController *) self;
    //[self.eventsTable reloadData];
    
    //self.view = self.eventsTable;
    [_eventsBox addSubview:self.eventsTable];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshStores) forControlEvents:UIControlEventValueChanged];
    [self.scrollView addSubview:self.refreshControl];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSEventsCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.eventsTable registerNib:nib forCellReuseIdentifier:@"HHSEventsCell"];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:0];
    [self.view addConstraint:rightConstraint];
    
    /*self.contentHeightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:0
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:800];
    [self.view addConstraint:self.contentHeightConstraint];
     */
    self.viewLoaded = YES;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self fillAll];
    
    //CGRect eventsFrame = eventsTable.frame;
    //eventsFrame.size.height = 600;//eventsTable.contentSize.height;
    //eventsTable.frame = eventsFrame;

}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    //necessary to resize the Events TableView
    [self fillEvents];
}

-(void)fillAll
{
    [self fillSchedule];
    [self fillLunch];
    [self fillNews];
    [self fillDailyAnn];
    [self fillEvents];
    
    if (self.owner.splitViewController && [self.schedulesStore allArticles]>0 ) {
        [self sendToDetailPager:0 parentViewController:(HHSCategoryVC*)self.owner.schedulesTVC];
    }
    
}

- (void)fillSchedule
{
    if ( [[_schedulesStore allArticles] count] >0) {
        NSArray *articleList = [[NSArray alloc] initWithArray:[_schedulesStore allArticles]];

        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [articleList sortedArrayUsingDescriptors:descriptors];

        HHSArticle *article = sortedArray[0];
        if ([sortedArray count] >=2) {
            NSDate *todayDate = [[NSDate alloc] init];
            NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:todayDate];
            NSInteger todayMonth = [todayComp month];
            NSInteger todayDay = [todayComp day];
            NSInteger todayHour = [todayComp hour];
            
            if (todayHour >=14) {
                NSDate *firstDate = article.date;
                NSDateComponents *firstComp =[[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstDate];
                NSInteger firstMonth = [firstComp month];
                NSInteger firstDay = [firstComp day];
                
                if ((todayMonth == firstMonth) && (todayDay == firstDay)) {
                    article = sortedArray[1];
                    self.skipToday = YES;
                }
            }
        }
        
        self.scheduleArticle = article;

        self.schedTitle.text = article.title;
        //self.schedTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
        static NSDateFormatter *dateFormatter;
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"EEE, MMM d";
            //dateFormatter.timeStyle = NSDateFormatterNoStyle;
        }
    
    
        //Use filtered NSDate object to set dateLabel contents
        self.schedDate.text = [dateFormatter stringFromDate:article.date];
        //self.schedDate.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
        NSString *initial = [article.title substringToIndex:1];
        if ([initial isEqualToString:@"A"]) {
            self.schedIcon.image = _images[@"a"];
        }
        else if ([initial isEqualToString:@"B"]) {
            self.schedIcon.image = _images[@"b"];
        }
        else if ([initial isEqualToString:@"C"]) {
            self.schedIcon.image = _images[@"c"];
        }
        else if ([initial isEqualToString:@"D"]) {
            self.schedIcon.image = _images[@"d"];
        }
        else {
            self.schedIcon.image = _images[@"star"];
        }
        
            }
    [self hideIfReady];
}

- (void)fillLunch
{
    if ( [[_lunchStore allArticles] count] >0) {
        NSArray *articleList = [[NSArray alloc] initWithArray:[_lunchStore allArticles]];
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [articleList sortedArrayUsingDescriptors:descriptors];
        
        NSDate *schedDate = self.scheduleArticle.date;
        
        for (HHSArticle *article in sortedArray) {
            NSDate *lunchDate = article.date;
            if ([lunchDate compare:schedDate] == 0) {
                self.lunchTitle.text = [NSString stringWithFormat:@"Lunch: %@", article.title];
                self.lunchArticle = article;
            }
        }
    }
    [self hideIfReady];
}

- (void)fillNews
{
    if ( [[_newsStore allArticles] count] >0) {
        NSArray *articleList = [[NSArray alloc ] initWithArray:[_newsStore allArticles]];
    
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [articleList sortedArrayUsingDescriptors:descriptors];
        NSArray* reversedArray = [[sortedArray reverseObjectEnumerator] allObjects];
    
        HHSArticle *article = reversedArray[0];
        self.newsArticle = article;
    
        self.newsTitle.text = article.title;
        //self.newsTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
        self.newsImage.image = article.thumbnail;
        
    }
    [self hideIfReady];
}

- (void)fillDailyAnn
{
    if ( [[_dailyAnnStore allArticles] count] >0) {
        NSArray *articleList = [[NSArray alloc] initWithArray:[_dailyAnnStore allArticles]];
    
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [articleList sortedArrayUsingDescriptors:descriptors];
        
        NSArray* reversedArray = [[sortedArray reverseObjectEnumerator] allObjects];
        
        HHSArticle *article = reversedArray[0];
        self.dailyAnnArticle = article;
        
        NSString *titleString = article.title;
        titleString = [titleString stringByReplacingOccurrencesOfString:@"Daily Announcements" withString:@""];
        titleString = [titleString stringByReplacingOccurrencesOfString:@"DAILY ANNOUNCEMENTS" withString:@""];
        
        NSDate *titleDate;
        NSString *formattedTitle = [[NSString alloc] init];
        
        static NSDateFormatter *displayFormat;
        if (displayFormat == nil) {
            displayFormat = [[NSDateFormatter alloc] init];
            displayFormat.dateFormat = @"EEEE, MMMM d";
        }
        
        static NSDateFormatter *testFormat;
        if (testFormat == nil) {
            testFormat= [[NSDateFormatter alloc] init];
            testFormat.dateFormat = @"MMMM d, yyyy";
            [testFormat setLenient:YES];
        }
        
        static NSDateFormatter *testFormat2;
        if (testFormat2 == nil) {
            testFormat2= [[NSDateFormatter alloc] init];
            testFormat2.dateFormat = @"EEEE, MMMM d";
            [testFormat2 setLenient:YES];
        }
        
        titleDate = [testFormat dateFromString:titleString];
        formattedTitle = [displayFormat stringFromDate:titleDate];
        
        if (formattedTitle == nil) {
            titleDate = [testFormat dateFromString:titleString];
            formattedTitle = [displayFormat stringFromDate:titleDate];
        }
        
        if (formattedTitle == nil) {
            formattedTitle = titleString;
        }
        
        //Use filtered NSDate object to set dateLabel contents
        self.dailyAnnTitle.text = formattedTitle;
        //self.dailyAnnTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
    }
    [self hideIfReady];
}

- (void) fillEvents
{
    if ( [[_eventsStore allArticles] count] >0) {
        NSArray *articles = [[NSArray alloc] initWithArray:[_eventsStore allArticles]];
    
        self.eventsArticles = [[NSMutableArray alloc] init];
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [articles sortedArrayUsingDescriptors:descriptors];
        
        [self.eventsArticles removeAllObjects];
        [self.eventsTable reloadData];
        
        int currentDay = -1;
        int numSections = (int)[self.eventsArticles count];
        int numRows = 0;
        if (numSections >0){
            numRows = (int)[self.eventsArticles[numSections-1] count];
            
            HHSArticle *lastArticle = self.eventsArticles[numSections-1][numRows-1];
            if(lastArticle){
                
                NSCalendar *lastcal = [NSCalendar currentCalendar];
                NSDateComponents *lastcomponents = [lastcal components:NSDayCalendarUnit fromDate:lastArticle.date];
                currentDay = (int)[lastcomponents day];
                numRows++;
            }
        }
        
        //[self.eventsTable beginUpdates];
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        
        for (HHSArticle *art in sortedArray) {
            NSDate *date=art.date;
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:NSDayCalendarUnit fromDate:date];
            int thisDay = (int)[components day];
            
            if(thisDay != currentDay) {
                numSections++;
                numRows=1;
                
                //only display two days of events
                if (numSections >=3) {
                    break;
                }
                [self.eventsArticles addObject:[[NSMutableArray alloc] init]];
                //[self.eventsTable insertSections:[NSIndexSet indexSetWithIndex:numSections-1] withRowAnimation:UITableViewRowAnimationNone];
                
            }
            currentDay = thisDay;
            
            //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numRows-1 inSection:numSections-1];
            //[indexPaths addObject:indexPath];
            [self.eventsArticles[numSections-1] addObject:art];
        }
        
        [self.eventsTable beginUpdates];
        for (int i=0 ;  i < [self.eventsArticles count]; i++) {
            [self.eventsTable insertSections:[NSIndexSet indexSetWithIndex:i] withRowAnimation:UITableViewRowAnimationNone];
            NSArray *arts = self.eventsArticles[i];
            for (int j=0; j < [arts count]; j++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                [indexPaths addObject:indexPath];
            }
        }
        [self.eventsTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.eventsTable endUpdates];
        
        [self.eventsTable reloadData];
        
        //[self.eventsStore saveChanges];
        
        //[self.activityView stopAnimating];
        
        CGFloat newHeight = (CGFloat)[indexPaths count]*_eventsCellHeight +2*_eventsHeaderHeight;
        
        CGRect tvframe = [self.eventsTable frame];
        [self.eventsTable setFrame:CGRectMake(tvframe.origin.x,
                                       tvframe.origin.y,
                                       tvframe.size.width-10,
                                       tvframe.size.height+newHeight)];
        
        CGRect cvframe = [self.contentView frame];
        [self.contentView setFrame:CGRectMake(cvframe.origin.x,
                                              0,
                                              cvframe.size.width,
                                              cvframe.size.height+newHeight)];
        
        CGRect scframe = [self.scrollView frame];
        self.scrollView.contentSize = CGSizeMake(scframe.size.width,
                                              scframe.size.height+newHeight);

        
    }
    [self hideIfReady];
}

-(void)hideIfReady
{
    if (self.owner.currentView == nil) {
        BOOL ready = (_scheduleArticle != nil) && (_newsArticle != nil)
            && (_dailyAnnArticle != nil) && (_eventsArticles != nil);
    
        if (ready) {
            [self.owner hideWaiting];
            [self.refreshControl endRefreshing];
            if(self.owner.splitViewController) {
                [self sendToDetailPager:0 parentViewController:(HHSCategoryVC*)self.owner.schedulesTVC];
            }
        }
    }
}

- (IBAction)scheduleButtonClicked:(id)sender {
    //HHSScheduleDetailsViewController *vc = [[HHSScheduleDetailsViewController alloc] init];
    
    int index = 0;
    if (_skipToday) {
        index++;
    }
    
    [self sendToDetailPager:index parentViewController:(HHSCategoryVC*)self.owner.schedulesTVC];
}

- (IBAction)newsButtonClicked:(id)sender {
    //HHSNewsDetailsViewController *vc = [[HHSNewsDetailsViewController alloc] init];
    int index = 0;
    
    [self sendToDetailPager:index parentViewController:(HHSCategoryVC*)self.owner.newsTVC];
}

- (IBAction)dailyAnnButtonClicked:(id)sender {
    //HHSDailyAnnDetailsViewController *vc = [[HHSDailyAnnDetailsViewController alloc] init];
    int index = 0;
    
    [self sendToDetailPager:index parentViewController:(HHSCategoryVC*)self.owner.dailyAnnTVC];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.eventsArticles count]; //1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.eventsArticles[section] count];  //[self.articlesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSEventsCell"];
    
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    // Get the specific earthquake for this row.
    HHSArticle *article = self.eventsArticles[section][row];
    
    //Configure the cell with the BNRItem
    cell.titleLabel.text = article.title;
    //cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"h:mm a";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    //Use filtered NSDate object to set dateLabel contents
    NSString *time = [dateFormatter stringFromDate:article.date];
    if ([time isEqual:@"12:00 AM"]) {
        cell.timeLabel.text = @"All Day";
    } else {
        cell.timeLabel.text = time;
    }
    //cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //HHSEventsDetailsViewController *vc = [[HHSEventsDetailsViewController alloc] init];
    int index = 0;
    for (int j=0; j<=indexPath.section; j++) {
        for (int i=0; i<[self.eventsArticles[j] count]; i++) {
            if ((j==indexPath.section) && (i==indexPath.row)) {
                break;
            }
            index++;
        }
    }

    [self sendToDetailPager:index parentViewController:(HHSCategoryVC*)self.owner.eventsTVC];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, _eventsHeaderHeight+10)];
    /* Create custom view to display section header... */
    UILabel *label;
        label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, tableView.frame.size.width-8, _eventsHeaderHeight)];
    //NSString *string =@"";
    /* Section header is in 0th index... */
    HHSArticle *article = self.eventsArticles[section][0];
    NSDate *date = article.date;
    static NSDateFormatter *headerFormat;
    if (!headerFormat) {
        headerFormat = [[NSDateFormatter alloc] init];
        headerFormat.dateFormat = @"EEEE, MMMM d, YYYY";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    NSString *dateString =[headerFormat stringFromDate:date];
    
    [label setText:dateString];
    [view addSubview:label];
    //label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    //[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:0.4]]; //your background color...
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return _eventsHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _eventsCellHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    /*
    if (barButtonItem == self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = nil;
    }
    */
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
    
     [hhsnvc setCurrentPopoverController:pc];*/
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
     /*self.popoverController = pc;
     UINavigationController *nvc = svc.viewControllers[0];
     HHSNavViewController *hhsnvc = nvc.viewControllers[0];
     
     [hhsnvc setCurrentPopoverController:pc];
     */
    
}

- (NSUInteger)splitViewControllerSupportedInterfaceOrientations:(UISplitViewController *)splitViewController {
    return UIInterfaceOrientationMaskLandscape;
}


- (void)navigationControllerSelectedItem:(id)item {
    // If a popover controller is visible, hide it
    if (popoverController) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

-(void)refreshStores {
    [self.owner refreshStores];
}

-(void)sendToDetailPager:(int)index parentViewController:(HHSCategoryVC *)viewController {
    
    HHSDetailPager *pager = [[HHSDetailPager alloc] init];
    if(viewController == nil) {
        viewController = (HHSCategoryVC*)self.owner.schedulesTVC;
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
