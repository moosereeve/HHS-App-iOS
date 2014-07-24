//
//  HHSImageStore.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHSArticle.h"

@interface HHSImageStore : NSObject

+ (instancetype)sharedStore;

- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (void)setImageWithUrlString:(NSString *)urlString forArticle:(HHSArticle *)article;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;


@end
