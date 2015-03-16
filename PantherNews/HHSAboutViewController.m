//
//  HHSAboutViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 3/9/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSAboutViewController.h"

@interface HHSAboutViewController ()

@end

@implementation HHSAboutViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.pagerIndex = 7;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableString *text = [[NSMutableString alloc] initWithString:@"Holliston High School\n"];
    [text appendString:@"Holliston, MA, USA\n\n"];
    [text appendString:@"App version "];
    [text appendString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [text appendString:@"\n\nDeveloped, designed, and maintained by\n"];
    [text appendString:@"Tom Reeve, HHS Tech Integration Specialist\n"];
    [text appendString:@"ReeveT@Holliston.k12.ma.us"];
    
    [self.textView setText:text];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
