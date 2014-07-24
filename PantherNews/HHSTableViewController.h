//
//  HHSTableViewController.h
//  
//
//  Created by Thomas Reeve on 6/23/14.
//
//

@protocol HHSTableViewControllerDelegate <NSObject>
- (void)refreshDone:(int)type;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end

#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"
@class HHSArticle;

@interface HHSTableViewController : UITableViewController <UISplitViewControllerDelegate>
{
    UIPopoverController *popoverController;
}
@property (nonatomic) UIPopoverController *popoverController;


@property (assign) id <HHSTableViewControllerDelegate> delegate;

@property (nonatomic, copy) NSArray *articles;
@property (nonatomic, strong) HHSArticleStore *articleStore;
@property (nonatomic) NSDictionary *parserElementNames;
@property (nonatomic, strong) NSMutableArray *sectionGroups;
@property (nonatomic) NSMutableArray *articlesList;

//values that the parser should scan for
@property (nonatomic, strong) NSString *feedUrlString;
@property (nonatomic) int numberOfSections;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

- (void)getArticlesFromFeed;
- (void)updateTableViewForDynamicTypeSize;


@end
