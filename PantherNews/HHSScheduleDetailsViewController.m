//
//  HHSScheduleDetailsViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSScheduleDetailsViewController.h"
#import "HHSArticle.h"

@interface HHSScheduleDetailsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailsTextView;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@property (strong, nonatomic) NSDictionary *images;

@end

@implementation HHSScheduleDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        //[defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
        
        UIImage *a = [UIImage imageNamed:@"a-50"];
        UIImage *b = [UIImage imageNamed:@"b-50"];
        UIImage *c = [UIImage imageNamed:@"c-50"];
        UIImage *d = [UIImage imageNamed:@"d-50"];
        UIImage *star = [UIImage imageNamed:@"star-50"];
        
        _images = @{@"a" : a,
                    @"b" : b,
                    @"c" : c,
                    @"d" : d,
                    @"star" : star };
        
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
    self.detailsTextView.text = article.details;
    
    //You will need an NSDateFormatter taht will turn a date into a simple date string
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d, YYYY";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    //Use filtered NSDate object to set dateLabel contents
    NSDate *date = article.date;
    if (date) {
        self.dateLabel.text = [dateFormatter stringFromDate:date];
    }
    
    NSString *initial = [article.title substringToIndex:1];
    if ([initial isEqualToString:@"A"]) {
        self.iconView.image = _images[@"a"];
    }
    else if ([initial isEqualToString:@"B"]) {
        self.iconView.image = _images[@"b"];
    }
    else if ([initial isEqualToString:@"C"]) {
        self.iconView.image = _images[@"c"];
    }
    else if ([initial isEqualToString:@"D"]) {
        self.iconView.image = _images[@"d"];
    }
    else {
        self.iconView.image = _images[@"star"];
    }

    
    
    //[self.detailsTextView setFont:[UIFont systemFontOfSize:16]];
    
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
    
    [self roundFrameCorners:self.dateLabel];
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
