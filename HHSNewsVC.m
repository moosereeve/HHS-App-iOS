//
//  HHSNewsVC.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSNewsVC.h"
#import "HHSNewsCell.h"
#import "HHSNewsDetailsViewController.h"
#import "HHSImageStore.h"
#import "HHSMainViewController.h"
#import "HHSDetailPager.h"


@interface HHSNewsVC ()

@end

@implementation HHSNewsVC

- (id)initWithStore:(HHSArticleStore *)store
{
    self = [super initWithStore:store];    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"School News";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 40;
    [self.view addSubview:self.tableView];
    
    //Load the NIB file
    UINib *nib = [UINib nibWithNibName:@"HHSNewsCell" bundle:nil];
    
    //Register this NIB, which contains the cell
    [self.tableView registerNib:nib forCellReuseIdentifier:@"HHSNewsCell"];
    
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
        [self sendToDetailPager:0 parentViewController:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    HHSNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HHSNewsCell"];
    
    // Get the specific earthquake for this row.
    HHSArticle *article = (self.articlesList)[indexPath.row];
    
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
    //cell.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
    
    cell.thumbnailView.image = article.thumbnail;
    
    //__weak HHSNewsCell *weakCell = cell;
    
    cell.actionBlock = ^{NSLog(@"Going to show image for %@", article);
        
        //HHSNewsCell *strongCell = weakCell;
        
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            NSString *articleKey = article.articleKey;
            
            //If there is no image, we don't need to display anything
            UIImage *img = [[HHSImageStore sharedStore] imageForKey:articleKey];
            if (!img) {
                return;
            }
            
            //Make a rectangle for the frame of the thumbnail relative to table view
            //CGRect rect = [self.view convertRect:strongCell.thumbnailView.bounds
            //                fromView:strongCell.thumbnailView];
            
            //Create a new BNRImageViewController and set its image
            //BNRImageViewController *ivc = [[BNRImageViewController alloc] init];
            //ivc.image = img;
            
            ////Present a 600x600 popover from the rect
            //self.imagePopover = [[UIPopoverController alloc] initWithContentViewController:ivc];
            //self.imagePopover.delegate = self;
            //self.imagePopover.popoverContentSize = CGSizeMake(600, 600);
            //[self.imagePopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } ;
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendToDetailPager:indexPath.row parentViewController:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSArray *articles = [[self articleStore] allArticles];
    UIViewController *returnVC = [UIViewController alloc];
    
    int index = [(HHSNewsDetailsViewController *)viewController articleNumber];
    
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
    
    int index = [(HHSNewsDetailsViewController *)viewController articleNumber];
    
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
    
    HHSNewsDetailsViewController *detailvc = [[HHSNewsDetailsViewController alloc] init];
    if ([articles count]>0) {
        detailvc.articleNumber = index;
        detailvc.article = articles[index];
    }
    return detailvc;
}

@end
