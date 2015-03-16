//
//  HHSArticle.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HHSArticle : NSObject <NSCoding>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy) NSString *articleKey;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, strong) UIImage *thumbnail;

+(instancetype) randomArticle;
-(void) setThumbnailFromImage:(UIImage *)image;
-(void) setImageFromImage:(UIImage *)image;

@end
