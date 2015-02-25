//
//  HHSArticleStore.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHSArticle.h"
@class HHSMainViewController;

@interface HHSArticleStore : NSObject

@property (nonatomic, readonly, copy) NSDictionary *Articles;
@property BOOL downloadError;

-(instancetype)initWithType:(int)type
                parserNames:(NSDictionary *)parserNames
              feedUrlString:(NSString *)feedUrlString
            sortNowToFuture:(BOOL)sortOrder
       triggersNotification:(BOOL)triggersNotification
                      owner:(HHSMainViewController *)owner;

-(int)getType;
-(HHSArticle *)newArticle;
-(void)addTempArticle:(HHSArticle *)article;
-(NSArray *)allArticles;
-(HHSArticle *)findArticle:(HHSArticle *)articleToCheck;
-(void)removeItem:(HHSArticle *)item;

-(void)getArticlesFromFeed;
-(void)getEventsFromFeed;
-(void)getArticlesInBackground;
-(void)getEventsInBackground;
-(void)parsingDone;
+(BOOL)needsUpdating;

+(int)HHSArticleStoreTypeSchedules;
+(int)HHSArticleStoreTypeEvents;
+(int)HHSArticleStoreTypeNews;
+(int)HHSArticleStoreTypeDailyAnns;
+(int)HHSArticleStoreTypeLunch;

@end
