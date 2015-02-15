//
//  HHSEventsDetailsViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/22/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHSArticle.h"

@interface HHSEventsDetailsViewController : UIViewController

@property (nonatomic, strong) HHSArticle *article;
@property (nonatomic) int articleNumber;


@end
