//
//  HHSXmlParser.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/21/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "APLParseOperation.h"
#import "HHSArticle.h"
#import "HHSArticleStore.h"
#import "HHSImageStore.h"

// NSNotification name for sending earthquake data back to the app delegate
NSString *kAddArticlesNotificationName = @"AddArticlesNotif";

// NSNotification userInfo key for obtaining the earthquake data
NSString *kArticleResultsKey = @"ArticleResultsKey";

// NSNotification name for reporting errors
NSString *kArticlesErrorNotificationName = @"ArticleErrorNotif";

// NSNotification userInfo key for obtaining the error message
NSString *kArticlesMessageErrorKey = @"ArticleMsgErrorKey";




@interface APLParseOperation () <NSXMLParserDelegate>

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


@implementation APLParseOperation
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

// The main function for this NSOperation, to start the parsing.
- (void)main {
    
    /*
     It's also possible to have NSXMLParser download the data, by passing it a URL, but this is not desirable because it gives less control over the network, particularly in responding to connection errors.
     */
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.articleData];
    [parser setDelegate:self];
    [parser parse];
    
    /*
     Depending on the total number of earthquakes parsed, the last batch might not have been a "full" batch, and thus not been part of the regular batch transfer. So, we check the count of the array and, if necessary, send it to the main thread.
     */
    /*if ([self.currentParseBatch count] > 0) {
        [self performSelectorOnMainThread:@selector(addArticlesToList:) withObject:self.currentParseBatch waitUntilDone:NO];
    }*/
    [self performSelectorOnMainThread:@selector(parsingDone) withObject:nil waitUntilDone:YES];
    //[self.currentArticleStore parsingDone];
}


#pragma mark - Parser constants

/*
 Limit the number of parsed earthquakes to 50 (a given day may have more than 50 earthquakes around the world, so we only take the first 50).
 */
static const NSUInteger kMaximumNumberOfArticlesToParse = 25;

/*
 When an Earthquake object has been fully constructed, it must be passed to the main thread and the table view in RootViewController must be reloaded to display it. It is not efficient to do this for every Earthquake object - the overhead in communicating between the threads and reloading the table exceed the benefit to the user. Instead, we pass the objects in batches, sized by the constant below. In your application, the optimal batch size will vary depending on the amount of data in the object and other factors, as appropriate.
 */
static NSUInteger const kSizeOfArticleBatch = 40;

// Reduce potential parsing errors by using string constants declared in a single place.



#pragma mark - NSXMLParser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    /*
     If the number of parsed earthquakes is greater than kMaximumNumberOfEarthquakesToParse, abort the parse.
     */
    if (_parsedArticleCounter >= kMaximumNumberOfArticlesToParse) {
        /*
         Use the flag didAbortParsing to distinguish between this deliberate stop and other parser errors.
         */
        _didAbortParsing = YES;
        [parser abortParsing];
    }
    if ([elementName isEqualToString:_kEntryElementName]) {
        HHSArticle *article = [[HHSArticle alloc] init];
        self.currentArticleObject = article;
    }
    else if ([elementName isEqualToString:_kLinkElementName]) {
        NSString *relAttribute = [attributeDict valueForKey:@"rel"];
        if ([relAttribute isEqualToString:@"alternate"]) {
            NSString *link = [attributeDict valueForKey:@"href"];
            self.currentArticleObject.url = [NSURL URLWithString:link];
        }
    }
    else if ([elementName isEqualToString:_kDateElementName]) {
        if ([_kStartTimeElementName isEqualToString:@""]){
            _accumulatingParsedCharacterData = YES;
            [self.currentParsedCharacterData setString:@""];
        } else {
            NSString *startDateAttribute = [attributeDict valueForKey:@"startTime"];
            NSDate *date = [self makeDateFromString:startDateAttribute];
        
            if (date) {
                self.currentArticleObject.date = date;
            }
        }
    }
    else if ([elementName isEqualToString:_kTitleElementName] || [elementName isEqualToString:_kDetailsElementName]) {
        // For the 'title', 'updated', or 'georss:point' element begin accumulating parsed character data.
        // The contents are collected in parser:foundCharacters:.
        _accumulatingParsedCharacterData = YES;
        // The mutable string needs to be reset to empty.
        [self.currentParsedCharacterData setString:@""];
    }
    else if([_kKeepHtmlTags isEqualToString:@"keep"]) {

        [self.currentParsedCharacterData appendString:@"<"];
        [self.currentParsedCharacterData appendString:elementName];
        NSArray *allKeys = [attributeDict allKeys];
        
        //add all attributes back into the tags
        for (NSString *key in allKeys) {
            NSString *value = attributeDict[key];
            [self.currentParsedCharacterData appendString:@" "];
            [self.currentParsedCharacterData appendString:key];
            [self.currentParsedCharacterData appendString:@"=\""];
            [self.currentParsedCharacterData appendString:value];
            [self.currentParsedCharacterData appendString:@"\""];
        }
        [self.currentParsedCharacterData appendString:@">"];

        if (([elementName isEqualToString:@"img"]) && (_currentImgSrc == nil)) {
            
            _currentImgSrc = attributeDict[@"src"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:_kEntryElementName]) {
        
        HHSArticle *existingArticle = [_currentArticleStore
                                       findArticle:self.currentArticleObject];
        if (existingArticle) {
            self.currentArticleObject = existingArticle;
        }
        if(_currentImgSrc){
            [[HHSImageStore sharedStore] setImageWithUrlString:_currentImgSrc forArticle:self.currentArticleObject];
        }
        _currentImgSrc = nil;
        
        [self.currentParseBatch addObject:self.currentArticleObject];
        [self.currentArticleStore addTempArticle:self.currentArticleObject];
        
        _parsedArticleCounter++;
        if ([self.currentParseBatch count] >= kSizeOfArticleBatch) {
            //[self.currentArticleStore parsingDone];
            [self performSelectorOnMainThread:@selector(parsingDone) withObject:nil waitUntilDone:YES];
            //[self performSelectorOnMainThread:@selector(addArticlesToList:) withObject:self.currentParseBatch waitUntilDone:YES];
            self.currentParseBatch = [NSMutableArray array];
            [self.currentArticleStore parsingDone];
        }
    }
    else if ([elementName isEqualToString:_kTitleElementName]) {
        /*
         The title element contains the magnitude and location in the following format:
         <title>M 3.6, Virgin Islands region<title/>
         Extract the magnitude and the location using a scanner:
         */
        //NSScanner *scanner = [NSScanner scannerWithString:self.currentParsedCharacterData];
        // Scan past the "M " before the magnitude.
        /*if ([scanner scanString:@"M " intoString:NULL]) {
            CGFloat magnitude;
            if ([scanner scanFloat:&magnitude]) {
                self.currentArticleObject.magnitude = magnitude;
                // Scan past the ", " before the title.
                if ([scanner scanString:@", " intoString:NULL]) {
                    NSString *location = nil;
                    // Scan the remainer of the string.
                    if ([scanner scanUpToCharactersFromSet:
                         [NSCharacterSet illegalCharacterSet] intoString:&location]) {
                        self.currentArticleObject.location = location;
                    }
                }
            }
        }*/
        self.currentArticleObject.title = [NSString stringWithString:self.currentParsedCharacterData];
    }
    else if ([elementName isEqualToString:_kDateElementName]) {
        if ([_kStartTimeElementName isEqualToString:@""]) {
            NSString *dateString = [NSString stringWithString:self.currentParsedCharacterData];
            self.currentArticleObject.date = [self makeDateFromString:dateString];
        }
        
    }
    else if ([elementName isEqualToString:_kDetailsElementName]) {
        self.currentArticleObject.details = self.currentParsedCharacterData;
         _accumulatingParsedCharacterData = NO;
        

    }
    else if([_kKeepHtmlTags isEqualToString:@"keep"]) {
            [self.currentParsedCharacterData appendString:@"</"];
            [self.currentParsedCharacterData appendString:elementName];
            [self.currentParsedCharacterData appendString:@">"];
    }
    else if ([_kKeepHtmlTags isEqualToString:@"convertToLineBreaks"]) {
        self.currentParsedCharacterData = [[self.currentParsedCharacterData stringByReplacingOccurrencesOfString:@"\n" withString:@""] mutableCopy];

        if ([elementName isEqualToString:@"p"] || [elementName isEqualToString:@"br"] || [elementName isEqualToString:@"div"] ) {
                [self.currentParsedCharacterData appendString:@"\r"];
        }
    }
}

/**
 This method is called by the parser when it find parsed character data ("PCDATA") in an element. The parser is not guaranteed to deliver all of the parsed character data for an element in a single invocation, so it is necessary to accumulate character data until the end of the element is reached.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if (_accumulatingParsedCharacterData) {
        // If the current element is one whose content we care about, append 'string'
        // to the property that holds the content of the current element.
        //
        [self.currentParsedCharacterData appendString:string];
    }
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