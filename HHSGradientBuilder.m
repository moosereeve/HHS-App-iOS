//
//  HHSGradientBuilder.m
//  PantherNews
//
//  Created by Thomas Reeve on 2/12/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSGradientBuilder.h"

@implementation HHSGradientBuilder

+(void) buildGradient:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor
{
    /*CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[startColor CGColor], (id)[endColor CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
     */
}

+(void) buildGradient:(UIView *)view {
    UIColor *startColor = [UIColor colorWithRed:(181/255.0) green:(30/255.0) blue:(18/255.0) alpha:1]; /*#b51e12*/
    UIColor *endColor = [UIColor colorWithRed:0.439 green:0.075 blue:0.043 alpha:1]; /*70130b*/
    
    [HHSGradientBuilder buildGradient:view startColor:startColor endColor:endColor];
}

@end
