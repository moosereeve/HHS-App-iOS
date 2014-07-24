//
//  HHSXmlParser.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSArticleStore.h"

NSString *kAddArticlesNotificationName;
NSString *kArticleResultsKey;
NSString *kArticlesErrorNotificationName;
NSString *kArticlesMessageErrorKey;

@interface APLParseOperation : NSOperation

@property (copy, readonly) NSData *articleData;

-(id)initWithData:(NSData *)parseData elementNames:(NSDictionary *)elementNames store:(HHSArticleStore *)articleStore;

@end
