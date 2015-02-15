//
//  HHSMenuController.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSMainViewController.h"
#import "SWRevealViewController.h"

@interface HHSMenuController : UIViewController
@property (nonatomic, weak) HHSMainViewController *mainViewController;
@property (strong, nonatomic) SWRevealViewController *swViewController;

@end
