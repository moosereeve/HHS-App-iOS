//
//  HHSMenuController.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/13/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSMenuController.h"
#import "HHSGradientBuilder.h"

@interface HHSMenuController ()
@property (nonatomic, weak) IBOutlet UIView *containerView;

@end

@implementation HHSMenuController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [HHSGradientBuilder buildGradient:self.view startColor:[UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1] endColor:[UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goToHome:(id)sender
{
    [self.mainViewController jumpToPage:0];
    [[self revealViewController] revealToggleAnimated:YES];
    
}

- (IBAction)goToSchedules:(id)sender
{
    [self.mainViewController jumpToPage:1];
    [[self revealViewController] revealToggleAnimated:YES];
    
}

- (IBAction)goToDailyAnns:(id)sender
{
    [self.mainViewController jumpToPage:3];
    [[self revealViewController] revealToggleAnimated:YES];
}

- (IBAction)goToNews:(id)sender
{
    [self.mainViewController jumpToPage:2];
    [[self revealViewController] revealToggleAnimated:YES];
}

- (IBAction)goToEvents:(id)sender
{
    [self.mainViewController jumpToPage:4];
    [[self revealViewController] revealToggleAnimated:YES];
}

- (IBAction)goToLunch:(id)sender
{
    [self.mainViewController jumpToPage:5];
    [[self revealViewController] revealToggleAnimated:YES];
}

- (IBAction)goToWebsite:(id)sender
{
    NSURL *url = [[NSURL alloc] initWithString:@"http://hhs.holliston.k12.ma.us"];
    [[UIApplication sharedApplication] openURL:url];
    [[self revealViewController] revealToggleAnimated:YES];
}

- (IBAction)refreshDataButtonPushed:(id)sender
{
    [[self revealViewController] revealToggleAnimated:YES];
    [self.mainViewController refreshDataButtonPushed];
    
}


@end
