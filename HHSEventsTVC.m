//
//  HHSEventsTVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSEventsTVC.h"
#import "HHSEventsCell.h"
#import "HHSEventsDetailsViewController.h"
#import "HHSNavViewController.h"
#import "HHSDetailPager.h"

@interface HHSEventsTVC ()
@property (nonatomic) NSMutableArray *articlesList;

@end

@implementation HHSEventsTVC

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Events";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSEventsCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSEventsCell"];
    
    [self reloadArticlesFromStore];
    
}

- (void)reloadArticlesFromStore {
    NSArray *articles = [self.articleStore allArticles];
    
    if (self.articleStore.downloadError) {
        [self.owner hideWaiting];
        return;
    }
    
    if ((articles == nil) || !(self.viewLoaded) || (self.articleStore.downloadError)) {
        return;
    }
    
    
    [self.articlesList removeAllObjects];
    [self.tableView reloadData];
    
    int currentDay = -1;
    int numSections = (int)[self.articlesList count];
    int numRows = 0;
    if (numSections >0){
        numRows = (int)[self.articlesList[numSections-1] count];
        
        HHSArticle *lastArticle = self.articlesList[numSections-1][numRows-1];
        if(lastArticle){
            
            NSCalendar *lastcal = [NSCalendar currentCalendar];
            NSDateComponents *lastcomponents = [lastcal components:NSDayCalendarUnit fromDate:lastArticle.date];
            currentDay = (int)[lastcomponents day];
            numRows++;
        }
    }
    
    [self.tableView beginUpdates];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (HHSArticle *art in articles) {
        NSDate *date=art.date;
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:NSDayCalendarUnit fromDate:date];
        int thisDay = (int)[components day];
        
        if(thisDay != currentDay) {
            [self.articlesList addObject:[[NSMutableArray alloc] init]];
            numSections++;
            numRows=1;
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:numSections-1] withRowAnimation:UITableViewRowAnimationNone];
            
        }
        currentDay = thisDay;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numRows-1 inSection:numSections-1];
        [indexPaths addObject:indexPath];
        [self.articlesList[numSections-1] addObject:art];
    }
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    [self.tableView endUpdates];
    
    if (self.owner.currentView == self) {
        [self.owner hideWaiting];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [self.articlesList count]; //1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.articlesList[section] count];  //[self.articlesList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSEventsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSEventsCell"];
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //HHSEventsDetailsViewController *vc = [[HHSEventsDetailsViewController alloc] init];
    
    //NSArray *items = [[BNRItemStore sharedStore] allItems];
    int index = 0;
    for (int j=0; j<=indexPath.section; j++) {
        for (int i=0; i<[self.articlesList[j] count]; i++) {
            if ((j==indexPath.section) && (i==indexPath.row)) {
                break;
            }
            index++;
        }
    }
    HHSDetailPager *pager = [[HHSDetailPager alloc] init];
    
    pager.articleStore = self.articleStore;
    pager.parent = self;
    pager.startingArticleIndex = index;
    
    //HHSArticle *selectedArticle = self.articlesList[indexPath.section][indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    //vc.article = selectedArticle;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:pager animated:YES];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label;
    if (section == 0 ) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, tableView.frame.size.width, 18)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 18)];
        
    }
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    //NSString *string =@"";
    /* Section header is in 0th index... */
    HHSArticle *article = self.articlesList[section][0];
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
    //label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];    //[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int returnval = 20;
    if (section == 0) {
        returnval = 40;
    }
    return returnval;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSEventsDetailsViewController *)viewController articleNumber];
    
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
    
    int index = [(HHSEventsDetailsViewController *)viewController articleNumber];
    
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
    
    HHSEventsDetailsViewController *detailvc = [[HHSEventsDetailsViewController alloc] init];
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
