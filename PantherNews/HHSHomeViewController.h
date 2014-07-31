//
//  HHSHomeViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 7/23/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

@protocol HHSTableViewControllerDelegate <NSObject>
- (void)refreshDone:(int)type;
-(void)setCurrentPopoverController:(UIPopoverController *)poc;
@end

#import <UIKit/UIKit.h>
#import "HHSArticleStore.h"

@interface HHSHomeViewController : UIViewController <UITableViewDelegate, UISplitViewControllerDelegate, HHSTableViewControllerDelegate>
{
    UIPopoverController *popoverController;
}
@property (nonatomic) UIPopoverController *popoverController;
@property (assign) id <HHSTableViewControllerDelegate> delegate;

@property (nonatomic, weak) HHSArticleStore *schedulesStore;
@property (nonatomic, weak) HHSArticleStore *newsStore;
@property (nonatomic, weak) HHSArticleStore *eventsStore;
@property (nonatomic, weak) HHSArticleStore *dailyAnnStore;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *schedTitle;
@property (weak, nonatomic) IBOutlet UILabel *schedDate;
@property (weak, nonatomic) IBOutlet UIImageView *schedIcon;

@property (weak, nonatomic) IBOutlet UILabel *newsTitle;
@property (weak, nonatomic) IBOutlet UIImageView *newsImage;

@property (weak, nonatomic) IBOutlet UILabel *dailyAnnTitle;

@property (weak, nonatomic) IBOutlet UIView *eventsBox;

-(void) fillAll;

@end
