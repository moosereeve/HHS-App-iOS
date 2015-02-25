//
//  HHSNewsDetailsViewController.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSNewsDetailsViewController.h"
#import "HHSArticle.h"
#import "SHK.h"
#import "SHKItem.h"
#import "SHKActionSheet.h"

@interface HHSNewsDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *detailsWebView;

@end

@implementation HHSNewsDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        //[defaultCenter addObserver:self selector:@selector(updateFonts) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //UIInterfaceOrientation io = [[UIApplication sharedApplication] statusBarOrientation];
    //[self prepareViewsForOrientation:io];
    
    HHSArticle *article = self.article;
    
    //self.titleLabel.text = article.title;
    NSMutableString *detailsHTML = [[NSMutableString alloc] init];
    
    [detailsHTML appendString:@"<div style='font-family:Helvetica, sans-serif'>"];
    
    [detailsHTML appendString:@"<h2>"];
    [detailsHTML appendString:article.title];
    [detailsHTML appendString:@"</h2>"];
    
    
    //You will need an NSDateFormatter taht will turn a date into a simple date string
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"EEE, MMM d, YYYY";
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    [detailsHTML appendString:@"<h4><em>"];
    [detailsHTML appendString:[dateFormatter stringFromDate:article.date]];
    [detailsHTML appendString:@"</em></h4>"];
    
    [detailsHTML appendString:article.details];
    
    [detailsHTML appendString:@"</div>"];
    
    detailsHTML = [self cleanUpHTML:detailsHTML];
    
    //Use filtered NSDate object to set dateLabel contents
    //self.dateLabel.text = [dateFormatter stringFromDate:article.date];
    
    [self.detailsWebView loadHTMLString:detailsHTML baseURL:nil];
    
    //NSString *itemKey = self.item.itemKey;
    
    //Get the image for its image key from the image store
    //UIImage *imageToDisplay = [[BNRImageStore sharedStore] imageForKey:itemKey];
    
    //Use that image to put on the screen in the imageView
    //self.imageView.image = imageToDisplay;
    
    //[self updateFonts];
    
}

-(NSMutableString *)cleanUpHTML:(NSMutableString*)detailsHTML
{
    [detailsHTML replaceOccurrencesOfString:@"<img"
                                 withString:@"<img style='max-width: 100%' "
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];
    
    [detailsHTML replaceOccurrencesOfString:@"\n"
                                 withString:@"<br>"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];
    
    [detailsHTML replaceOccurrencesOfString:@"<br/>"
                                 withString:@"<br>"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];
    
    [detailsHTML replaceOccurrencesOfString:@"</br>"
                                 withString:@"<br>"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];

    [detailsHTML replaceOccurrencesOfString:@"<br><br>"
                                 withString:@"<br>"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];

    [detailsHTML replaceOccurrencesOfString:@"<br><br>"
                                 withString:@"<br>"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [detailsHTML length])];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<hr.+>" options:NSRegularExpressionCaseInsensitive error:nil];
    
    detailsHTML = [[regex stringByReplacingMatchesInString:detailsHTML options:0 range:NSMakeRange(0, [detailsHTML length]) withTemplate:@""] mutableCopy];
    
    
    if ((UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) && ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) )
    {
        
        [detailsHTML replaceOccurrencesOfString:@"float: left"
                                     withString:@""
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        [detailsHTML replaceOccurrencesOfString:@"float:left"
                                     withString:@""
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        [detailsHTML replaceOccurrencesOfString:@"float: right"
                                     withString:@""
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        [detailsHTML replaceOccurrencesOfString:@"float:right"
                                     withString:@""
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        [detailsHTML replaceOccurrencesOfString:@"display:inline"
                                     withString:@"display:block"
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        [detailsHTML replaceOccurrencesOfString:@"display: inline"
                                     withString:@"display:block"
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [detailsHTML length])];
        // code for Portrait orientation
    }
    return detailsHTML;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateFonts
{
    /*self.dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.detailsTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    */
}

- (IBAction)share:(id)sender
{
    SHKItem *item = [SHKItem URL:_article.url title:_article.title contentType:SHKURLContentTypeWebpage];
    
    [SHK setRootViewController:self.parentViewController];
    
    SHKActionSheet *actionSheet = [SHKActionSheet actionSheetForItem:item];
    
    [actionSheet showInView:self.view];
}

@end
