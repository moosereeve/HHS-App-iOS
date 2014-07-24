//
//  HHSArticleStore.h
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HHSArticle.h"

@interface HHSArticleStore : NSObject

@property (nonatomic, readonly, copy) NSDictionary *Articles;

-(instancetype)initWithType:(int)type;

-(HHSArticle *)createItem;
-(void)registerArticleInStore:(HHSArticle *)article;
-(NSArray *)allArticles;
-(HHSArticle *)findArticle:(HHSArticle *)articleToCheck;
-(void)removeItem:(HHSArticle *)item;
-(BOOL)saveChanges;
-(int)getType;

+(int)HHSArticleStoreTypeSchedules;
+(int)HHSArticleStoreTypeEvents;
+(int)HHSArticleStoreTypeNews;
+(int)HHSArticleStoreTypeDailyAnns;

@end
