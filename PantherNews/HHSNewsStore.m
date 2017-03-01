//
//  HHSNewsStore.m
//  PantherNews
//
//  Created by Thomas Reeve on 11/18/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSNewsStore.h"
#import "HHSJsonParseOperation.h"

@implementation HHSNewsStore

-(void)getArticlesFromFeed
{
    //preserve the latest news article. After the download, we'll
    //compare to see if there is a new article
    NSArray *articles = [self allArticles];
    if ([articles count] >0 ) {
        self.formerNewsKey = ((HHSArticle *)articles[0]).articleKey;
    } else {
        self.formerNewsKey = nil;
    }
    
    [super getArticlesFromFeed];
}

-(id)setupParse:(NSData *)data
{
    HHSJsonParseOperation *parseOperation = [[HHSJsonParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];
    return parseOperation;
}


@end
