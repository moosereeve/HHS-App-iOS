//
//  HHSJsonParseOperation.m
//  PantherNews
//
//  Created by Thomas Reeve on 11/20/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSJsonParseOperation.h"
#import "HHSArticle.h"
#import "HHSArticleStore.h"
#import "HHSImageStore.h"

@interface HHSJsonParseOperation ()

@property (nonatomic) HHSArticle *currentArticleObject;
@property (nonatomic, weak) HHSArticleStore *currentArticleStore;
@property (nonatomic) NSMutableArray *currentParseBatch;
@property (nonatomic) NSMutableString *currentParsedCharacterData;
@property (nonatomic) NSMutableString *currentImgSrc;

@property (nonatomic) NSDictionary *parserElementNames;

@property (nonatomic, strong) NSString *kEntryElementName;
@property (nonatomic, strong) NSString *kLinkElementName;
@property (nonatomic, strong) NSString *kTitleElementName;
@property (nonatomic, strong) NSString *kDateElementName;
@property (nonatomic, strong) NSString *kDetailsElementName;
@property (nonatomic, strong) NSString *kStartTimeElementName;
@property (nonatomic, strong) NSString *kKeepHtmlTags;

@property (nonatomic, strong)NSString *mAddArticlesNotificationName;
@property (nonatomic, strong)NSString *mArticleResultsKey;
@property (nonatomic, strong)NSString *mArticlesErrorNotificationName;
@property (nonatomic, strong)NSString *mArticlesMessageErrorKey;
@end


@implementation HHSJsonParseOperation
{
    NSDateFormatter *_dateFormatter;
    
    BOOL _accumulatingParsedCharacterData;
    BOOL _didAbortParsing;
    NSUInteger _parsedArticleCounter;
}


- (id)initWithData:(NSData *)parseData elementNames:(NSDictionary *)elementNames store:(HHSArticleStore *)articleStore{
    
    self = [super init];
    if (self) {
        _articleData = [parseData copy];
        _currentArticleStore = articleStore;
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        //[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        
        _currentParseBatch = [[NSMutableArray alloc] init];
        _currentParsedCharacterData = [[NSMutableString alloc] init];
        
        _parserElementNames = elementNames;
        
        _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, articleStore.getType];
        _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, articleStore.getType];
        _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, articleStore.getType];
        _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, articleStore.getType];
        
        _kEntryElementName = _parserElementNames[@"entry"];
        _kLinkElementName = _parserElementNames[@"link"];
        _kTitleElementName = _parserElementNames[@"title"];
        _kDateElementName =_parserElementNames[@"date"];
        _kStartTimeElementName =_parserElementNames[@"startTime"];
        _kDetailsElementName = _parserElementNames[@"details"];
        _kKeepHtmlTags = _parserElementNames[@"keepHtmlTags"];
        
    }
    return self;
}

- (void) main
{
    NSError *error;
    NSDictionary *calJson = [NSJSONSerialization JSONObjectWithData:_articleData options:kNilOptions error:&error];
    
    NSArray *items = [calJson valueForKeyPath:@"items"];
    
    for (int i=0; i<[items count]; i++) {
        NSDictionary *event = items[i];
        HHSArticle *article = [[HHSArticle alloc] init];
        
        article.title = [event objectForKey:_kTitleElementName];
        article.url = [event objectForKey:_kLinkElementName];
        NSDictionary *dateDict= [event objectForKey:_kDateElementName];
        for (NSString *key in dateDict) {
            NSRange range = [key rangeOfString:@"date"];
            if (range.location != NSNotFound) {
                NSString *dateString = [dateDict objectForKey:key];
                article.date = [self makeDateFromString:dateString];
            }
        }
        article.details = [event objectForKey:_kDetailsElementName];
        
        [self.currentArticleStore addTempArticle:article];
        
    }
    [self performSelectorOnMainThread:@selector(parsingDone) withObject:nil waitUntilDone:YES];
}


-(void)parsingDone
{
    [self.currentArticleStore parsingDone];
}

- (void)addArticlesToList:(NSArray *)articles {
    
    //assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:_mAddArticlesNotificationName object:self userInfo:@{_mArticleResultsKey: articles}];
}

/**
 An error occurred while parsing the earthquake data: post the error as an NSNotification to our app delegate.
 */
- (void)handleArticlesError:(NSError *)parseError {
    
    assert([NSThread isMainThread]);
    [[NSNotificationCenter defaultCenter] postNotificationName:_mArticlesErrorNotificationName object:self userInfo:@{_mArticlesMessageErrorKey: parseError}];
}

/**
 An error occurred while parsing the earthquake data, pass the error to the main thread for handling.
 (Note: don't report an error if we aborted the parse due to a max limit of earthquakes.)
 */
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
    if ([parseError code] != NSXMLParserDelegateAbortedParseError && !_didAbortParsing) {
        [self performSelectorOnMainThread:@selector(handleArticlesError:) withObject:parseError waitUntilDone:NO];
    }
}

- (NSDate *)makeDateFromString:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (dateString.length == 10) {
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    } else if (dateString.length == 25) {
        [dateFormatter setDateFormat:@"YYYY-MM-dd'T'HH:mm:ss'-05:00'"];
    } else if (dateString.length >10) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSz"];
    }
    // We will upload the date at UTC 0.
    //dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    // Format our date object to a suitable string.
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormatter dateFromString:dateString];
    
    return date;
    
}
@end
