//
//  HHSTableViewController.h
//  
//
//  Created by Thomas Reeve on 6/23/14.
//
//

//@protocol HHSTableViewControllerDelegate <NSObject>
//-(void)refreshDone:(int)type;
//-(void)setCurrentPopoverController:(UIPopoverController *)poc;
//@end

#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"
#import "HHSNavViewController.h"
@class HHSArticle;

@interface HHSTableViewController : UITableViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController *pageController;
@property (nonatomic) int pagerIndex;
@property (nonatomic, strong) HHSArticleStore *articleStore;
@property (nonatomic) NSMutableArray *articlesList;
@property (nonatomic, strong) NSMutableArray *sectionGroups;
@property (nonatomic) int numberOfSections;

@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic, weak) HHSNavViewController *owner;
@property BOOL isViewLoaded;

//@property (nonatomic, copy) NSArray *articles;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

-(instancetype)initWithStore:(HHSArticleStore *)store;
-(void)reloadArticlesFromStore;
-(void)downloadError;
-(UIViewController *)viewControllerAtIndex:(int)index;

@end
