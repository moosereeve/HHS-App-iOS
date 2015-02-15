//
//  HHSScheduleTableViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSScheduleTableViewController.h"
#import "HHSScheduleCell.h"
#import "HHSScheduleDetailsViewController.h"
#import "HHSNavViewController.h"
#import "HHSDetailPager.h"

@interface HHSScheduleTableViewController ()
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic) BOOL skipToday;
@end


@implementation HHSScheduleTableViewController

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Schedules";
        
        
        UIImage *a = [UIImage imageNamed:@"a"];
        UIImage *b = [UIImage imageNamed:@"b"];
        UIImage *c = [UIImage imageNamed:@"c"];
        UIImage *d = [UIImage imageNamed:@"d"];
        UIImage *star = [UIImage imageNamed:@"star"];
        
        _images = @{@"a" : a,
                    @"b" : b,
                    @"c" : c,
                    @"d" : d,
                    @"star" : star };
    }
    
    self.skipToday = NO;
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSScheduleCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSScheduleCell"];
    
    UIImage *headerImage = [UIImage imageNamed:@"books"];
    int screenWidth = [[UIScreen mainScreen] bounds].size.width;
    int origHeight = headerImage.size.height;
    int origWidth = headerImage.size.width;
    int newHeight = origHeight * screenWidth / origWidth;
    CGRect newImageRect = CGRectMake(0.0,0.0,screenWidth, newHeight);
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:newImageRect];
    imageView.image = headerImage;
    //imageView.bounds = newImageRect;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    UIView *headerView = [[UIView alloc] initWithFrame:newImageRect];
    [headerView addSubview:imageView];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.text = @"Schedules";
    [headerView addSubview:headerLabel];
    NSDictionary *views = NSDictionaryOfVariableBindings(headerLabel);
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerLabel]-|" options:nil metrics:nil views:views];
    [headerView addConstraints:constraints];
    
    self.tableView.tableHeaderView = headerView;
    
    [self reloadArticlesFromStore];
    
}

- (void)reloadArticlesFromStore {
    
    NSMutableArray *articles = [[self.articleStore allArticles] mutableCopy];
    
    if (self.articleStore.downloadError) {
        [self.owner hideWaiting];
        return;
    }
    
    if ((articles == nil) || !(self.viewLoaded) ) {
        return;
    }
    
    [self.articlesList removeAllObjects];
    [self.tableView reloadData];
    
    /*for (int i = 0; i< [self.tableView numberOfSections]; i++) {
       NSIndexSet *is = [[NSIndexSet alloc] initWithIndex:0];
        [self.tableView deleteSections:is withRowAnimation:UITableViewRowAnimationNone];
    }*/
    
    if ([articles count] >=2) {
        NSDate *todayDate = [[NSDate alloc] init];
        NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:todayDate];
        NSInteger todayMonth = [todayComp month];
        NSInteger todayDay = [todayComp day];
        NSInteger todayHour = [todayComp hour];
        
        if (todayHour >=14) {
            HHSArticle *firstArticle = (HHSArticle *) articles[0];
            NSDate *firstDate = firstArticle.date;
            NSDateComponents *firstComp =[[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstDate] ;
            NSInteger firstMonth = [firstComp month];
            NSInteger firstDay = [firstComp day];
            
            if ((todayMonth == firstMonth) && (todayDay == firstDay)) {
                [articles removeObjectAtIndex:0];
                self.skipToday = YES;
            }
        }
    }
    
    int currentWeek = -1;
    int numSections = 0;
    int numRows = 0;
    
    [self.tableView beginUpdates];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (HHSArticle *art in articles) {
        
        NSDate *date= art.date;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSWeekOfYearCalendarUnit fromDate:date];
        int weekOfYear = (int)[components weekOfYear];
        
        if(weekOfYear != currentWeek) {
            [self.articlesList addObject:[[NSMutableArray alloc] init]];
            numSections++;
            numRows=1;
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:numSections-1] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        currentWeek = weekOfYear;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numRows-1 inSection:numSections-1];
        [indexPaths addObject:indexPath];
        numRows++;
        
        [self.articlesList[numSections-1] addObject:art];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    [self.activityView stopAnimating];
    
    if (self.owner.currentView == self) {
        [self.owner hideWaiting];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.articlesList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articlesList[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSScheduleCell"];
    
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    // Get the specific earthquake for this row.
    HHSArticle *article = self.articlesList[section][row];
    
    //Configure the cell with the BNRItem
    cell.titleLabel.text = article.title;
    //cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    
    //Use filtered NSDate object to set dateLabel contents
    cell.dateLabel.text = [dateFormatter stringFromDate:article.date];
    //cell.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    NSString *initial = [article.title substringToIndex:1];
    if ([initial isEqualToString:@"A"]) {
        cell.iconView.image = _images[@"a"];
    }
    else if ([initial isEqualToString:@"B"]) {
        cell.iconView.image = _images[@"b"];
    }
    else if ([initial isEqualToString:@"C"]) {
        cell.iconView.image = _images[@"c"];
    }
    else if ([initial isEqualToString:@"D"]) {
        cell.iconView.image = _images[@"d"];
    }
    else {
        cell.iconView.image = _images[@"star"];
    }

    //cell.thumbnailView.image = item.thumbnail;
 
    //__weak BNRItemCell *weakCell = cell;
    
    //cell.actionBlock = ^{NSLog(@"Going to show image for %@", item);
 
        //BNRItemCell *strongCell = weakCell;
 
        //if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            //NSString *itemKey = item.itemKey;
 
            ////If there is no image, we don't need to display anything
            //UIImage *img = [[BNRImageStore sharedStore] imageForKey:itemKey];
            //if (!img) {
            //    return;
            //}
 
            //Make a rectangle for the frame of the thumbnail relative to table view
            //CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
            //                            fromView:strongCell.thumbnailView];
 
            ////Create a new BNRImageViewController and set its image
            //BNRImageViewController *ivc = [[BNRImageViewController alloc] init];
            //ivc.image = img;
 
            ////Present a 600x600 popover from the rect
            //self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            //self.imagePopover.delegate = self;
            //self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            //[self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        //} ;
    //};
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //HHSScheduleDetailsViewController *vc = [[HHSScheduleDetailsViewController alloc] init];
    int index = 0;
    for (int j=0; j<=indexPath.section; j++) {
        for (int i=0; i<[self.articlesList[j] count]; i++) {
            if ((j==indexPath.section) && (i==indexPath.row)) {
                break;
            }
            index++;
        }
    }
    if (_skipToday) {
        index++;
    }
    
    HHSDetailPager *pager = [[HHSDetailPager alloc] init];
    
    pager.articleStore = self.articleStore;
    pager.parent = self;
    pager.startingArticleIndex = index;
    
    
    
    //HHSArticle *selectedArticle = self.articlesList[indexPath.section][indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    //vc.article = selectedArticle;
    //vc.articleNumber = (int) indexPath.row;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:pager animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSScheduleDetailsViewController *)viewController articleNumber];
    
    index++;
    if (index >=articles.count) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSScheduleDetailsViewController *)viewController articleNumber];
    
    index--;
    if (index <0) {
        returnVC = nil;
    } else {
        returnVC =[self viewControllerAtIndex:index];
    }
    
    return returnVC;
    
}

-(UIViewController *)viewControllerAtIndex:(int)index {
    
    NSArray *articles = [[self articleStore] allArticles];
    
    HHSScheduleDetailsViewController *detailvc = [[HHSScheduleDetailsViewController alloc] init];
    detailvc.articleNumber = index;
    detailvc.article = articles[index];
    
    return detailvc;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return 5;
}
-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}



@end
