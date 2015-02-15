//
//  HHSGradientBuilder.h
//  PantherNews
//
//  Created by Thomas Reeve on 2/12/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHSGradientBuilder : NSObject
+(void) buildGradient:(UIView *)view startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
+(void) buildGradient:(UIView *)view;
@end
