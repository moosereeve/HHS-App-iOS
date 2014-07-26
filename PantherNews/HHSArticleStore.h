//
//  HHSArticleStore.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHSArticle.h"
@class HHSTableViewController;

@interface HHSArticleStore : NSObject

@property (nonatomic, readonly, copy) NSDictionary *Articles;
//values that the parser should scan for

-(instancetype)initWithType:(int)type
                parserNames:(NSDictionary *)parserNames
              feedUrlString:(NSString *)feedUrlString
                     owners:(NSArray *)owners;

-(HHSArticle *)createItem;
-(void)registerArticleInStore:(HHSArticle *)article;
-(NSArray *)allArticles;
-(HHSArticle *)findArticle:(HHSArticle *)articleToCheck;
-(void)removeItem:(HHSArticle *)item;
-(BOOL)saveChanges;
-(int)getType;
-(void)replaceAllArticlesWith:(NSArray *)articleList;
-(void)getArticlesFromFeed;

+(int)HHSArticleStoreTypeSchedules;
+(int)HHSArticleStoreTypeEvents;
+(int)HHSArticleStoreTypeNews;
+(int)HHSArticleStoreTypeDailyAnns;

@end
