//
//  HHSEventsDetailsViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/22/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSEventsDetailsViewController.h"
#import "HHSArticle.h"
#import "HHSGradientBuilder.h"

@interface HHSEventsDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation HHSEventsDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    
    self.titleLabel.text = article.title;
    if (article.details == nil) {
        //skip
    } else {
        self.detailsTextView.text = article.details;
    }
    
    //You will need an NSDateFormatter taht will turn a date into a simple date string
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d, YYYY";
    }
    
    static NSDateFormatter *timeFormatter;
    if (!timeFormatter) {
        timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"h:mm a";
    }
    NSDate *date = article.date;
    if (date) {
        self.dateLabel.text = [dateFormatter stringFromDate:date];
        self.timeLabel.text = [timeFormatter stringFromDate:date];
    }
    
    [HHSGradientBuilder buildGradient:self.headerView];
    
    //NSString *itemKey = self.item.itemKey;
    
    //Get the image for its image key from the image store
    //UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:itemKey];
    
    //Use that image to put on the screen in the imageView
    //self.imageView.image = imageToDisplay;
    
    //[self updateFonts];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [self roundFrameCorners:self.titleLabel];
    [self roundFrameCorners:self.detailsTextView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)roundFrameCorners:(UIView *)view
{
    CGSize origFrameSize = view.frame.size;
    
    //THe rectangel of the thumbnail
    CGRect newRect = CGRectMake(0, 0, origFrameSize.width, origFrameSize.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
                                                    cornerRadius:5.0];
    
    CAShapeLayer* borderMaskLayer = [CAShapeLayer layer];
    [borderMaskLayer setFrame:view.bounds];
    borderMaskLayer.path = [path CGPath];
    view.layer.mask = borderMaskLayer;
    [view.layer setMasksToBounds:YES];
    
    //Cleanup image context resrouces; we're done
    UIGraphicsEndImageContext();
    
}

- (void)updateFonts
{
    //self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    //self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    //self.detailsTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
}



@end
