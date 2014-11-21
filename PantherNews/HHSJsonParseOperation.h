//
//  HHSJsonParseOperation.h
//  PantherNews
//
//  Created by Thomas Reeve on 11/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSArticleStore.h"

NSString *kAddArticlesNotificationName;
NSString *kArticleResultsKey;
NSString *kArticlesErrorNotificationName;
NSString *kArticlesMessageErrorKey;

@interface HHSJsonParseOperation : NSOperation

@property (copy, readonly) NSData *articleData;

-(id)initWithData:(NSData *)parseData elementNames:(NSDictionary *)elementNames store:(HHSArticleStore *)articleStore;

@end