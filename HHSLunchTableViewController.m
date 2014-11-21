//
//  HHSLunchTableViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSLunchTableViewController.h"
#import "HHSLunchCell.h"
#import "HHSLunchDetailsViewController.h"
#import "HHSNavViewController.h"

@interface HHSLunchTableViewController ()
@property (nonatomic, strong) NSDictionary *images;
@end


@implementation HHSLunchTableViewController

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Lunch Menus";
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSLunchCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSLunchCell"];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HHSLunchDetailsViewController *vc = [[HHSLunchDetailsViewController alloc] init];
    
    //NSArray *items = [[BNRItemStore sharedStore] allItems];
    HHSArticle *selectedArticle = self.articlesList[indexPath.section][indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    vc.article = selectedArticle;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


@end
