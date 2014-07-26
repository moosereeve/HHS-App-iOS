//
//  HHSEventsTableViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/22/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSEventsTableViewController.h"
#import "HHSEventsCell.h"
#import "HHSEventsDetailsViewController.h"

@interface HHSEventsTableViewController ()

@property (nonatomic) NSMutableArray *articlesList;
// queue that manages our NSOperation for parsing earthquake data


@end

@implementation HHSEventsTableViewController

- (id)init
{
    self = [super init];
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

    if ([[self.articleStore allArticles] count] >0) {
        [self retrieveArticles];
    } else {
        [self.articleStore getArticlesFromFeed];
    }
}

- (void)retrieveArticles {
    
    if ([[self.articleStore allArticles] count] == 0) {
        [self.articleStore getArticlesFromFeed];
    } else {
        NSArray *storeArticles = [self.articleStore allArticles] ;
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [storeArticles sortedArrayUsingDescriptors:descriptors];
        
        [self.articlesList removeAllObjects];
        NSArray *articles = [[NSArray alloc] initWithArray:[sortedArray copy]];
        
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
        
        [self.articleStore saveChanges];
        
        [self.delegate refreshDone:[HHSArticleStore HHSArticleStoreTypeEvents]];
        [self.activityView stopAnimating];

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
    cell.timeLabel.text = [dateFormatter stringFromDate:article.date];
    //cell.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
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
    HHSEventsDetailsViewController *vc = [[HHSEventsDetailsViewController alloc] init];
    
    //NSArray *items = [[BNRItemStore sharedStore] allItems];
    HHSArticle *selectedArticle = self.articlesList[indexPath.section][indexPath.row];
    
    //Give deatil view controller a pointer to the item object in the row
    vc.article = selectedArticle;
    
    //Piush it onto the top of the navigation controller's stack
    [self.navigationController pushViewController:vc animated:YES];
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

@end
