//
//  HHSLunchVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSLunchVC.h"
#import "HHSLunchCell.h"
#import "HHSLunchDetailsViewController.h"
#import "HHSMainViewController.h"
#import "HHSCategoryVC.h"
#import "HHSDetailPager.h"

@interface HHSLunchVC ()
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic) BOOL skipToday;
@property (nonatomic) int cellHeight;
@property (nonatomic) int headerHeight;

@end

@implementation HHSLunchVC

- (id)initWithStore:(HHSCalendarStore *)store
{
    self = [super initWithStore:(HHSArticleStore *)store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Lunch Menus";
        self.skipToday = NO;
        
        self.headerHeight = 30;
        self.cellHeight = 50;
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
    UINib *nib = [UINib nibWithNibName:@"HHSLunchCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSLunchCell"];
    
    [self reloadArticlesFromStore];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.owner.splitViewController) {
        [self sendToDetailPager:0 parentViewController:self];
    }
}

- (void)reloadArticlesFromStore {
    
    NSMutableArray *articles = [[self.articleStore allArticles] mutableCopy];
    
    [super reloadArticlesFromStore];
    
    if ((articles == nil) || !(self.isViewLoaded) ) {
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
        NSDateComponents *components = [cal components:NSCalendarUnitWeekOfYear fromDate:date];
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
    
    /*
     CGFloat newHeight = (CGFloat)[indexPaths count]*self.cellHeight +numSections*self.headerHeight;
    
    CGRect tvframe = [self.tableView frame];
    [self.tableView setFrame:CGRectMake(tvframe.origin.x,
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
    */
    if (self.owner.currentView == self) {
        [self.owner hideWaiting];
        [self sendToDetailPager:0 parentViewController:self];
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
    HHSLunchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSLunchCell"];
    
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
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerString = [[NSString alloc] init];
    
    if (section == 0) {
        headerString = @"This week";
    } else if (section == 1) {
        headerString =  @"Next week";
    } else if (section == 2) {
        headerString = @"Later";
    } else {
        headerString = @"";
    }
    return headerString;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //HHSLunchDetailsViewController *vc = [[HHSLunchDetailsViewController alloc] init];
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
    
    [self sendToDetailPager:index parentViewController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerHeight;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.headerHeight;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSLunchDetailsViewController *)viewController articleNumber];
    
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
    
    int index = [(HHSLunchDetailsViewController *)viewController articleNumber];
    
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
    
    HHSLunchDetailsViewController *detailvc = [[HHSLunchDetailsViewController alloc] init];
    if ([articles count]>0) {
        detailvc.articleNumber = index;
        detailvc.article = articles[index];
    }
    return detailvc;
}

@end
