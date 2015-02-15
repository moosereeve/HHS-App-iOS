//
//  HHSDailyAnnVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSDailyAnnVC.h"
#import "HHSDailyAnnCell.h"
#import "HHSDailyAnnDetailsViewController.h"
#import "HHSMainViewController.h"
#import "HHSDetailPager.h"

@interface HHSDailyAnnVC ()

@end

@implementation HHSDailyAnnVC

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Announcements";
        
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
    UINib *nib = [UINib nibWithNibName:@"HHSDailyAnnCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSDailyAnnCell"];
    
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
    
    NSInteger startingRow = [self.articlesList count];
    NSInteger articleCount = [articles count];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:articleCount];
    
    for (NSInteger row = startingRow; row < (startingRow + articleCount); row++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [indexPaths addObject:indexPath];
    }
    
    [self.articlesList addObjectsFromArray:articles];
    
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    if (self.owner.currentView == self) {
        [self.owner hideWaiting];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = (int)[self.articlesList count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //static NSString *kArticleCellID = @"ArticleCellID";
    HHSDailyAnnCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSDailyAnnCell"];
    
    // Get the specific earthquake for this row.
    HHSArticle *article = (self.articlesList)[indexPath.row];
    
    //Configure the cell with the BNRItem
    //cell.titleLabel.text = article.title;
    
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
    cell.dateLabel.text = formattedTitle;
    //cell.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendToDetailPager:indexPath.row parentViewController:self];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSDailyAnnDetailsViewController *)viewController articleNumber];
    
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
    
    int index = [(HHSDailyAnnDetailsViewController *)viewController articleNumber];
    
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
    
    HHSDailyAnnDetailsViewController *detailvc = [[HHSDailyAnnDetailsViewController alloc] init];
    detailvc.articleNumber = index;
    detailvc.article = articles[index];
    
    return detailvc;
}


@end
