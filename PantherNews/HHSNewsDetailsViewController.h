//
//  HHSNewsDetailsViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSArticle.h"
#import "SHK.h"

@interface HHSNewsDetailsViewController : UIViewController

@property (nonatomic, strong) HHSArticle *article;
@property (nonatomic) int articleNumber;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;

-(IBAction)share:(id)sender;

@end
