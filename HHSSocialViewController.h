//
//  HHSSocialViewController.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/24/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHSSocialViewController : UIViewController

@property (nonatomic) int pagerIndex;

-(IBAction) goToFacebook:(id)sender;
-(IBAction) gotoTwitter:(id)sender;
-(IBAction) goToGoogleplus:(id)sender;
-(IBAction) goToInstagram:(id)sender;
-(IBAction) goToYoutube:(id)sender;

@end
