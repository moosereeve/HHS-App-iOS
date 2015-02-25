//
//  HHSSocialViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/24/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSSocialViewController.h"

@interface HHSSocialViewController ()

@end

@implementation HHSSocialViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.pagerIndex = 6;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) goToFacebook:(id)sender
{
    NSURL *urlNative = [NSURL URLWithString:@"fb://profile/HollistonHigh"];
    NSURL *urlBrowser = [NSURL URLWithString:@"http://www.facebook.com/HollistonHigh"];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlNative]){
        [[UIApplication sharedApplication] openURL:urlNative];
    }
    else {
         [[UIApplication sharedApplication] openURL:urlBrowser];
    }
}
-(IBAction) gotoTwitter:(id)sender
{
    NSURL *urlNative = [NSURL URLWithString:@"twitter://user?screen_name=HollistonHigh"];
    NSURL *urlBrowser = [NSURL URLWithString:@"http://www.twitter.com/HollistonHigh"];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlNative]){
        [[UIApplication sharedApplication] openURL:urlNative];
    }
    else {
        [[UIApplication sharedApplication] openURL:urlBrowser];
    }
}
-(IBAction) goToGoogleplus:(id)sender
{
    
    NSURL *urlBrowser = [NSURL URLWithString:@"https://plus.google.com/b/109673162050529249669/109673162050529249669/posts"];
    [[UIApplication sharedApplication] openURL:urlBrowser];
    
}
-(IBAction) goToInstagram:(id)sender
{
    NSURL *urlNative = [NSURL URLWithString:@"instagram://user?username=HollistonHigh"];
    NSURL *urlBrowser = [NSURL URLWithString:@"http://instagram.com/HollistonHigh"];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlNative]){
        [[UIApplication sharedApplication] openURL:urlNative];
    }
    else {
        [[UIApplication sharedApplication] openURL:urlBrowser];
    }
}
-(IBAction) goToYoutube:(id)sender
{
    NSURL *urlBrowser = [NSURL URLWithString:@"https://www.youtube.com/channel/UCnDicx0qt2xP1t7O7NpbNOg"];
    [[UIApplication sharedApplication] openURL:urlBrowser];
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
