//
//  HHSEventsVC.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSCategoryVC.h"

@interface HHSEventsVC : HHSCategoryVC < UIPageViewControllerDataSource, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end