//
//  HHSDailyAnnDetailsViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSDailyAnnDetailsViewController.h"

#import "HHSArticle.h"

@interface HHSDailyAnnDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;

@end

@implementation HHSDailyAnnDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    //[self prepareViewsForOrientation:io];
    
    HHSArticle *article = self.article;
    
    //self.titleLabel.text = article.title;
    NSString *details = article.details;
    //details = [details stringByReplacingOccurrencesOfString:@"\n\n\n" withString:@"\n\n"];
    self.detailsTextView.text = details;
    
    //You will need an NSDateFormatter taht will turn a date into a simple date string
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d, YYYY";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    //Use filtered NSDate object to set dateLabel contents
    self.dateLabel.text = [dateFormatter stringFromDate:article.date];
    
    //NSString *itemKey = self.item.itemKey;
    
    //Get the image for its image key from the image store
    //UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:itemKey];
    
    //Use that image to put on the screen in the imageView
    //self.imageView.image = imageToDisplay;
    
    [self updateFonts];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFonts
{
    self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.detailsTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}
@end
