//
//  HHSSchedulesVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSSchedulesVC.h"
#import "HHSScheduleCell.h"
#import "HHSScheduleDetailsViewController.h"
#import "HHSMainViewController.h"
#import "HHSDetailPager.h"

@interface HHSSchedulesVC ()
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic) BOOL skipToday;
@property (nonatomic) int cellHeight;
@property (nonatomic) int headerHeight;
@property (nonatomic) int startIndex;

@end

@implementation HHSSchedulesVC

- (id)initWithStore:(HHSCalendarStore *)store
{
    self = [super initWithStore:(HHSArticleStore *)store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Schedules";
        
        
        UIImage *a = [UIImage imageNamed:@"a_sm"];
        UIImage *b = [UIImage imageNamed:@"b_sm"];
        UIImage *c = [UIImage imageNamed:@"c_sm"];
        UIImage *d = [UIImage imageNamed:@"d_sm"];
        UIImage *star = [UIImage imageNamed:@"star_sm"];
        
        _images = @{@"a" : a,
                    @"b" : b,
                    @"c" : c,
                    @"d" : d,
                    @"star" : star };
    }
    self.cellHeight = 50;
    self.headerHeight = 30;
    self.skipToday = NO;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSScheduleCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSScheduleCell"];
    
    [self reloadArticlesFromStore];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.owner.splitViewController) {
        [self sendToDetailPager:0 parentViewController:self];
    }
    
}

- (void)reloadArticlesFromStore {
    
    [super reloadArticlesFromStore];
    
    NSMutableArray *articles = [[self.articleStore allArticles] mutableCopy];
    
    if ((articles == nil) || !(self.isViewLoaded) ) {
        return;
    }
    
    [self.articlesList removeAllObjects];
    [self.tableView reloadData];
    
    /*for (int i = 0; i< [self.tableView numberOfSections]; i++) {
     NSIndexSet *is = [[NSIndexSet alloc] initWithIndex:0];
     [self.tableView deleteSections:is withRowAnimation:UITableViewRowAnimationNone];
     }*/
    
    NSDate *todayDate = [[NSDate alloc] init];
    NSDateComponents *todayComp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:todayDate];
    NSInteger todayMonth = [todayComp month];
    NSInteger todayDay = [todayComp day];
    NSInteger todayHour = [todayComp hour];
    NSInteger todayYear = [todayComp year];
    
    self.startIndex = 0;
    
    //work backward through the array to see find the earliest schedule, but not
    //eariler than today
    for (int ii= (int)([articles count]-1); ii>=0; ii--) {
        HHSArticle *tempArticle = articles[ii];
        NSDate *tempDate = tempArticle.date;
        NSDateComponents *tempComp = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:tempDate];
        NSInteger tempMonth = [tempComp month];
        NSInteger tempDay = [tempComp day];
        NSInteger tempYear = [tempComp year];
        
        if ((tempYear >= todayYear) && (tempMonth >= todayMonth) && (tempDay >= todayDay)) {
            self.startIndex = ii;
        }
    }
    
    if ([articles count] >=2) {
        
        if (todayHour >=14) {
            HHSArticle *firstArticle = (HHSArticle *) articles[self.startIndex];
            NSDate *firstDate = firstArticle.date;
            NSDateComponents *firstComp =[[NSCalendar currentCalendar] components:NSCalendarUnitMonth|NSCalendarUnitDay fromDate:firstDate] ;
            NSInteger firstMonth = [firstComp month];
            NSInteger firstDay = [firstComp day];
            
            if ((todayMonth == firstMonth) && (todayDay == firstDay)) {
                self.startIndex = self.startIndex +1;
                self.skipToday = YES;
            }
        }
    }
    
    int currentWeek = -1;
    int numSections = 0;
    int numRows = 0;
    
    [self.tableView beginUpdates];
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (int ii=self.startIndex; ii<[articles count]; ii++) {
        HHSArticle *art = articles[ii];
        
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
    HHSScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSScheduleCell"];
    
    int section = (int)indexPath.section;
    int row = (int)indexPath.row;
    
    HHSArticle *article = self.articlesList[section][row];
    
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
    //HHSScheduleDetailsViewController *vc = [[HHSScheduleDetailsViewController alloc] init];
    int index = self.startIndex;
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellHeight;
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
    if ([articles count]>0) {
        detailvc.articleNumber = index;
        detailvc.article = articles[index];
    }
    
    return detailvc;
}

@end
