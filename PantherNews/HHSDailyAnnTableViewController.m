//
//  HHSDailyAnnTableViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSDailyAnnTableViewController.h"
#import "HHSDailyAnnCell.h"
#import "HHSDailyAnnDetailsViewController.h"

@interface HHSDailyAnnTableViewController ()

@end

@implementation HHSDailyAnnTableViewController

- (id)init
{
    self = [super init];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Announcements";
        
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSDailyAnnCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSDailyAnnCell"];
    
    [self retrieveArticles];
}

/**
 The NSOperation "ParseOperation" calls addArticlesToList: via NSNotification, on the main thread which in turn calls this method, with batches of parsed objects.
 */
- (void)retrieveArticles {
    
    if ([[self.articleStore allArticles] count] == 0) {
        [self.articleStore getArticlesFromFeed];
    } else {
        NSArray *storeArticles = [self.articleStore allArticles] ;
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [storeArticles sortedArrayUsingDescriptors:descriptors];
        NSArray* reversedArray = [[sortedArray reverseObjectEnumerator] allObjects];
        NSArray *articles = [[NSArray alloc] initWithArray:reversedArray];
        
        [self.articleStore replaceAllArticlesWith:reversedArray];
        
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
        
        
        [self.articleStore saveChanges];
        
        [self.delegate refreshDone:[HHSArticleStore HHSArticleStoreTypeDailyAnns]];
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
    HHSDailyAnnDetailsViewController *vc = [[HHSDailyAnnDetailsViewController alloc] init];
    
    //NSArray *items = [[BNRItemStore sharedStore] allItems];
    HHSArticle *selectedArticle = self.articlesList[indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    vc.article = selectedArticle;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:vc animated:YES];
}



@end
