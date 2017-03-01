//
//  HHSCalendarStore.m
//  PantherNews
//
//  Created by Thomas Reeve on 11/18/15.
//  Copyright (c) 2015 Holliston High School. All rights reserved.
//

#import "HHSCalendarStore.h"
#import "HHSJsonParseOperation.h"

@implementation HHSCalendarStore

-(void)getArticlesFromFeed
{
    NSString *feedStringWithDates = [self getDateAdjustedFeed];
    self.feedUrl = [[NSURL alloc] initWithString:feedStringWithDates];
    //NSLog(@"feedStringWithDates =%@", feedStringWithDates);
    
    [super getArticlesFromFeed];

}

-(void)getArticlesInBackground
{
    NSString *feedStringWithDates = [self getDateAdjustedFeed];
    self.feedUrl = [[NSURL alloc] initWithString:feedStringWithDates];
    //NSLog(@"feedStringWithDates =%@", feedStringWithDates);
    
    [super getArticlesInBackground];
    
}

-(id)setupParse:(NSData *)data
{
    HHSJsonParseOperation *parseOperation = [[HHSJsonParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];
    return parseOperation;
}

-(NSString *)getDateAdjustedFeed
{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'00'%3A'00'%3A'00-05'%3A'00"];
    
    NSMutableString *feedStringWithDates = [[NSMutableString alloc] init];
    
    if ([self.feedUrlString containsString:@"?"]) {
        [feedStringWithDates setString:[NSString stringWithFormat:@"%@&timeMin=%@",self.feedUrlString, [df stringFromDate:now]]] ;
    } else {
        [feedStringWithDates setString:[NSString stringWithFormat:@"%@?timeMin=%@",self.feedUrlString, [df stringFromDate:now]]];
    }
    return feedStringWithDates;
}




@end
