//
//  HHSDetailPager.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/12/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSDetailPager.h"
#import "HHSCategoryVC.h"

@interface HHSDetailPager ()

@end

@implementation HHSDetailPager

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
    // Do any additional setup after loading the view.
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[self.pageController view] setFrame:[[self view] bounds]];

    self.pageController.dataSource = (id) self.parent;
    
    
    UIViewController *initialDetailsVC = [self.parent viewControllerAtIndex:self.startingArticleIndex];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialDetailsVC];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
}
- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
