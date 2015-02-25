//
//  HHSEventsVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSEventsVC.h"
#import "HHSEventsCell.h"
#import "HHSEventsDetailsViewController.h"
#import "HHSMainViewController.h"
#import "HHSDetailPager.h"

@interface HHSEventsVC ()
@property (nonatomic) NSMutableArray *articlesList;

@end

@implementation HHSEventsVC

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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSEventsCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSEventsCell"];
    
    [self reloadArticlesFromStore];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.owner.splitViewController) {
        [self sendToDetailPager:0 parentViewController:self];
    }
}


- (void)reloadArticlesFromStore {
    NSArray *articles = [self.articleStore allArticles];
    
    [super reloadArticlesFromStore];
    
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
        [self sendToDetailPager:0 parentViewController:self];
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
    [self sendToDetailPager:index parentViewController:self];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 10, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label;
    label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:16]];
    
    [view setBackgroundColor:[UIColor whiteColor]];
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
    
    /*NSDictionary *dict = @{@"label":label};
    NSArray *constraints =
    [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label]-10-|" options:(0) metrics:nil views:dict];
    [view addConstraints:constraints];*/
    //label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];    //[view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int returnval = 30;
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
    if ([articles count]>0) {
        detailvc.articleNumber = index;
        detailvc.article = articles[index];
    }
    return detailvc;
}

@end
