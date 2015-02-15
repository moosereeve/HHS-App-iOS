//
//  HHSArticle.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSArticle.h"

@implementation HHSArticle

- (instancetype) init
{
    self = [super init];
    
    if (self) {
        _title = [[NSString alloc] init];
        _url = [[NSURL alloc] init];
        _details = [[NSString alloc] init];
        _date = [[NSDate alloc] init];
        _thumbnail = [[UIImage alloc] init];
    
        //Create an NSUUID object - and get its string representation
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        _articleKey = key;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                  link:(NSURL *)link
                    details:(NSString *)details
{
    //Call the supercalss's designated initializer
    self = [super init];
    
    //Did the superclass's designated initializer succeed?
    if (self) {
        //Give the instance variables intial values
        _title = title;
        _url = link;
        _details = details;
        
        //Set _dateCreated to current date and time
        _date = [[NSDate alloc] init];
        
        //Create an NSUUID object - and get its string representation
        NSUUID *uuid = [[NSUUID alloc] init];
        NSString *key = [uuid UUIDString];
        _articleKey = key;
    }
    
    //Return the address of the newly initialized object
    return self;
}


+ (instancetype)randomArticle
{
    //Note that NSInteger is not an object but a type definition
    NSDictionary *schedMap = @{@"A" : @"A Day: ABCD",
                               @"B" : @"B Day: BCDA",
                               @"C" : @"C Day: CDAB",
                               @"D" : @"D Day: DABC"};
        
    
    NSString *schedLetter = [NSString stringWithFormat:@"%c",
                             'A' + arc4random() %4];
    
    NSString *scheduleTitle = schedMap[schedLetter];
                       
    
    
    NSString *randomDetails = [NSString stringWithFormat:@"%c%c%c%c%c",
                                    '0' + arc4random() %10,
                                    'A' + arc4random() %26,
                                    '0' + arc4random() %10,
                                    'A' + arc4random() %26,
                                    '0' + arc4random() %10];
    
    NSURL *url = [NSURL URLWithString:@"http://www.somelink.com"];
    
    HHSArticle *newItem = [[self alloc] initWithTitle:scheduleTitle
                                                 link:url
                                              details:randomDetails];
    return newItem;
    
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.articleKey forKey:@"articleKey"];
    [aCoder encodeObject:self.details forKey:@"details"];
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];
    
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _title = [aDecoder decodeObjectForKey:@"title"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _date = [aDecoder decodeObjectForKey:@"date"];
        _articleKey = [aDecoder decodeObjectForKey:@"articleKey"];
        _details = [aDecoder decodeObjectForKey:@"details"];
        _thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
        
    }
    return self;
}

- (void)setThumbnailFromImage:(UIImage *)image
{
    CGSize origImageSize = image.size;
    
    //THe rectangel of the thumbnail
    CGRect newRect = CGRectMake(0, 0, 400, 400);
    
    //Figure out a scaling ratio to make sure we maintain the same aspect ratio
    float ratio = MAX(newRect.size.width / origImageSize.width,
                      newRect.size.height / origImageSize.height);
    
    //Create a transparent bitmap context with a scaling factor
    //equal to that of the screen
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, 0.0);
    
    //Create a path that is a rounded rectangle
    //UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    
    //Make all subsequent drawing clip to this rounded rectangle
    //[path addClip];
    
    //Center the iamge in the thumbnail rectangel
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width) / 2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    //Draw the image on it
    [image drawInRect:projectRect];
    
    //Get the image from the image context; keep it as out htumbnail
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    self.thumbnail = smallImage;
    
    //Cleanup image context resrouces; we're done
    UIGraphicsEndImageContext();
    
}




@end
