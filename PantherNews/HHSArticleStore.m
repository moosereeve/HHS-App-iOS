//
//  HHSArticleStore.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSArticleStore.h"
#import "HHSArticle.h"
#import "HHSImageStore.h"
#import "HHSTableViewController.h"
#import "HHSHomeViewController.h"
#import "APLParseOperation.h"
#import "HHSJsonParseOperation.h"

@interface HHSArticleStore ()

@property (nonatomic) NSMutableDictionary *privateItems;
@property (nonatomic) NSMutableDictionary *tempItems;
@property (nonatomic) int type;
@property (nonatomic) BOOL sortNowToFuture;

@property (nonatomic) NSOperationQueue *parseQueue;
@property (nonatomic, strong) NSString *feedUrlString;
@property (nonatomic) NSDictionary *parserElementNames;
@property BOOL parsingInBackgroundFetch;
@property BOOL currentlyParsing;

//@property (nonatomic) NSArray *owners;
@property (nonatomic, weak) HHSNavViewController *owner;

@property (nonatomic, strong)NSString *mAddArticlesNotificationName;
@property (nonatomic, strong)NSString *mArticleResultsKey;
@property (nonatomic, strong)NSString *mArticlesErrorNotificationName;
@property (nonatomic, strong)NSString *mArticlesMessageErrorKey;


@end

@implementation HHSArticleStore

- (instancetype)init
{
    [NSException raise:@"Wrong initializer"
                format:@"Use +[HHSArticleStore initWithType:HHSArticleStore.SCHEDULE]"];
    return nil;
}

-(instancetype)initWithType:(int)type
                parserNames:(NSDictionary *)parserNames
              feedUrlString:(NSString *)feedUrlString
                       sortNowToFuture:(BOOL)sortOrder
                     owner:(HHSNavViewController *)owner
{
    
    self = [super init];
    if (self) {
        _type = type;
        _owner = owner;
        _parserElementNames = parserNames;
        _feedUrlString = feedUrlString;
        _sortNowToFuture = sortOrder;
        _downloadError = NO;
        _currentlyParsing = NO;
        
        NSString *path = [self articleArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        
        //If the array hadn't been saved previously, crete one
        if (!_privateItems) {
            _privateItems = [[NSMutableDictionary alloc] init];
            [self getArticlesFromFeed];
        }
    }
    return self;
}

-(int)getType
{
    return self.type;
}

#pragma mark article management

- (NSArray *)allArticles
{
    if ([self.privateItems count] == 0) {
        [self getArticlesFromFeed];
        return nil;
    } else {
        NSArray *newArticles = [self.privateItems allValues] ;
        
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:_sortNowToFuture];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        NSArray *sortedArray = [newArticles sortedArrayUsingDescriptors:descriptors];

        return sortedArray;
    }
}

- (HHSArticle *)newArticle
{
    HHSArticle *item = [[HHSArticle alloc] init];
    
    //[self.privateItems  addObject:item];
    self.privateItems[item.articleKey] = item;
    
    return item;
}

- (void)addTempArticle:(HHSArticle *)article
{
    self.tempItems[article.articleKey] = article;
}

- (void)addArticle:(HHSArticle *)article
{
    self.privateItems[article.articleKey] = article;
}

-(void)populateStoreWith:(NSArray *)articleList
{
    //NSDictionary *backupOfItems = [[NSDictionary alloc] initWithDictionary:self.privateItems copyItems:YES];
    
    [self.privateItems removeAllObjects];
    for (HHSArticle *article in articleList) {
        [self addArticle:article];
    }
    
    [self saveStore];
    
}

- (HHSArticle *)findArticle:(HHSArticle *)articleToCheck
{
    HHSArticle *resultArticle = [[HHSArticle alloc] init];
    
    for (NSString *key in [self.privateItems allKeys]) {
        
        HHSArticle *article = self.privateItems[key];
        
        //NSString *u1 = article.url.absoluteString;
        //NSString *u2 = articleToCheck.url.absoluteString;
        
        if ([article.url.absoluteString isEqualToString:articleToCheck.url.absoluteString]){
            
            //copy article key from found article
            resultArticle.articleKey = article.articleKey;
    
            //replace with new content
            resultArticle.title = articleToCheck.title;
            resultArticle.details = articleToCheck.details;
            resultArticle.date = articleToCheck.date;
            resultArticle.url = articleToCheck.url;
            resultArticle.thumbnail = articleToCheck.thumbnail;
            
            return resultArticle;
        }
    }
    return nil;
}

-(void)removeItem:(HHSArticle *)article
{
    [self.privateItems removeObjectForKey:article.articleKey];
    
    NSString *key = article.articleKey;
    [[HHSImageStore sharedStore] deleteImageForKey:key];
}

-(void)removeAllArticles
{
    for (HHSArticle *article in self.privateItems) {
        [self.privateItems removeObjectForKey:article.articleKey];
    
        NSString *key = article.articleKey;
        [[HHSImageStore sharedStore] deleteImageForKey:key];
    }
}

#pragma mark file encoding

- (NSString *)articleArchivePath
{
    //Make sure that the first arguemnt is NSDocumentDirectory
    //and not NSDocumentation Directory
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Get the one document from the list
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *pathComponent = [NSString stringWithFormat:@"articles%d.archive", self.type];

    return [documentDirectory stringByAppendingPathComponent:pathComponent];
}

+(NSString *)downloadDatePath
{
    //Make sure that the first arguemnt is NSDocumentDirectory
    //and not NSDocumentation Directory
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //Get the one document from the list
    NSString *documentDirectory = [documentDirectories firstObject];
    
    NSString *pathComponent = [NSString stringWithFormat:@"lastdownload.archive"];
    
    return [documentDirectory stringByAppendingPathComponent:pathComponent];
}

- (BOOL)saveStore
{
    NSString *path = self.articleArchivePath;
    NSString *datePath = [HHSArticleStore downloadDatePath];
    
    NSDate *now = [[NSDate alloc] init];
    NSArray *dateArray = [[NSArray alloc] initWithObjects:now, nil];
    [dateArray writeToFile:datePath atomically:YES];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    
    //Returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

+(BOOL)needsUpdating
{
    BOOL update = NO;
    
    NSString *datePath = [HHSArticleStore downloadDatePath];
    NSArray *dateArray = [[NSArray alloc] initWithContentsOfFile:datePath];
    NSDate *lastDate = [[NSDate alloc] init];
    
    if (dateArray == nil) {
        update = YES;
    } else if ((dateArray != nil) && ([dateArray count]>0)) {
        lastDate = dateArray[0];
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *lastDateComp = [cal components:(NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:lastDate];
        int lastYear =   [lastDateComp year];
        int lastMonth =  [lastDateComp month];
        int lastDay =    [lastDateComp day];
        int lastHour =   13; //[lastDateComp hour];
        int lastMinute = 35; //[lastDateComp minute];
        
        NSDate *today = [[NSDate alloc] init];
        NSDateComponents *todayComp = [cal components:(NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:today];
        int todayYear =   [todayComp year];
        int todayMonth =  [todayComp month];
        int todayDay =    [todayComp day];
        int todayHour =   16;//[todayComp hour];
        int todayMinute = 15;//[todayComp minute];
        
        if (todayYear > lastYear) {
            update = YES;
        } else if (todayMonth > lastMonth) {
            update = YES;
        } else if (todayDay > lastDay) {
            update = YES;
        } else if ((todayHour >= 4) && (lastHour <4)) {
            update = YES;
        } else if ((todayHour >= 8) && (lastHour <8)) {
            update = YES;
        } else if ((todayHour == 13) && (todayMinute >=30)) {
            if ((lastHour <13) || ((lastHour == 13) && (lastMinute <30)) ){
                update = YES;
            }
        } else if(todayHour >13) {
            if ((lastHour <13) || ((lastHour == 13) && (lastMinute <30)) ){
                update = YES;
            }
        }
    }
    return update;
}

#pragma mark downloading

-(void)getArticlesFromFeed
{
    if (_currentlyParsing == YES) {
        return;
    }
    _currentlyParsing = YES;
    _tempItems = [[NSMutableDictionary alloc] init];
    _parsingInBackgroundFetch = NO;
    
    _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self getType]];
    _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self getType]];
    _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self getType]];
    _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self getType]];
    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    
    NSURL *urlFeed = [[NSURL alloc] initWithString:self.feedUrlString];
    NSURLRequest *articleURLRequest =
    [NSURLRequest requestWithURL:urlFeed];
    
    // send the async request (note that the completion block will be called on the main thread)
    //
    // note: using the block-based "sendAsynchronousRequest" is preferred, and useful for
    // small data transfers that are likely to succeed. If you doing large data transfers,
    // consider using the NSURLConnectionDelegate-based APIs.
    //
    [NSURLConnection sendAsynchronousRequest:articleURLRequest
     // the NSOperationQueue upon which the handler block will be dispatched:
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self handleUrlConnectCompletion:response data:data error:error];
                               
                           }];
    
    // Start the status bar network activity indicator.
    // We'll turn it off when the connection finishes or experiences an error.
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addParseResultsToStore:)
                                                 name:_mAddArticlesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
}

-(void)getEventsFromFeed
{
    if (_currentlyParsing == YES) {
        return;
    }
    //_currentlyParsing = YES;
    _tempItems = [[NSMutableDictionary alloc] init];
    _parsingInBackgroundFetch = NO;
    
    _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self getType]];
    _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self getType]];
    _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self getType]];
    _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self getType]];
    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'00'%3A'00'%3A'00-05'%3A'00"];
    
    NSString *feedStringWithDates = [NSString stringWithFormat:@"%@&timeMin=%@",self.feedUrlString, [df stringFromDate:now]];
    NSURL *urlFeed = [[NSURL alloc] initWithString:feedStringWithDates];
    NSURLRequest *articleURLRequest =
    [NSURLRequest requestWithURL:urlFeed];
    
    // send the async request (note that the completion block will be called on the main thread)
    //
    // note: using the block-based "sendAsynchronousRequest" is preferred, and useful for
    // small data transfers that are likely to succeed. If you doing large data transfers,
    // consider using the NSURLConnectionDelegate-based APIs.
    //
    [NSURLConnection sendAsynchronousRequest:articleURLRequest
     // the NSOperationQueue upon which the handler block will be dispatched:
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self handleUrlConnectCompletion:response data:data error:error];
                               
                           }];
    
    // Start the status bar network activity indicator.
    // We'll turn it off when the connection finishes or experiences an error.
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addParseResultsToStore:)
                                                 name:_mAddArticlesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
}


-(void)getArticlesInBackground{
    _tempItems = [[NSMutableDictionary alloc] init];
    _parsingInBackgroundFetch = YES;
    
    _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self getType]];
    _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self getType]];
    _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self getType]];
    _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self getType]];
    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    
    NSURL *urlFeed = [[NSURL alloc] initWithString:self.feedUrlString];
    NSURLRequest *articleURLRequest = [NSURLRequest requestWithURL:urlFeed];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // send the async request (note that the completion block will be called on the main thread)
    //
    // note: using the block-based "sendAsynchronousRequest" is preferred, and useful for
    // small data transfers that are likely to succeed. If you doing large data transfers,
    // consider using the NSURLConnectionDelegate-based APIs.
    //
    self.parseQueue = [NSOperationQueue new];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:articleURLRequest returningResponse:&response error:&error];
    
    [self handleUrlConnectCompletion:response data:data error:error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addParseResultsToStore:)
                                                 name:_mAddArticlesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
}

-(void)getEventsInBackground{
    _tempItems = [[NSMutableDictionary alloc] init];
    _parsingInBackgroundFetch = YES;
    
    _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self getType]];
    _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self getType]];
    _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self getType]];
    _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self getType]];
    
    /*
     Use NSURLConnection to asynchronously download the data. This means the main thread will not be blocked - the application will remain responsive to the user.
     
     IMPORTANT! The main thread of the application should never be blocked!
     Also, avoid synchronous network access on any thread.
     */
    
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd'T'00'%3A'00'%3A'00-05'%3A'00"];
    
    NSString *feedStringWithDates = [NSString stringWithFormat:@"%@&timeMin=%@",self.feedUrlString, [df stringFromDate:now]];
    NSURL *urlFeed = [[NSURL alloc] initWithString:feedStringWithDates];
    NSURLRequest *articleURLRequest = [NSURLRequest requestWithURL:urlFeed];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    // send the async request (note that the completion block will be called on the main thread)
    //
    // note: using the block-based "sendAsynchronousRequest" is preferred, and useful for
    // small data transfers that are likely to succeed. If you doing large data transfers,
    // consider using the NSURLConnectionDelegate-based APIs.
    //
    self.parseQueue = [NSOperationQueue new];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:articleURLRequest returningResponse:&response error:&error];
    
    [self handleUrlConnectCompletion:response data:data error:error];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addParseResultsToStore:)
                                                 name:_mAddArticlesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
}


-(void)handleUrlConnectCompletion:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    // back on the main thread, check for errors, if no errors start the parsing
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    // here we check for any returned NSError from the server, "and" we also check for any http response errors
    if (error != nil) {
        [self handleError:error];
    }
    else {
        // check for any response errors
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        int code = [httpResponse statusCode];
        NSString *mimeType = [response MIMEType];
        if ((([httpResponse statusCode]/100) == 2) ) {
            // Update the UI and start parsing the data,
            // Spawn an NSOperation to parse the earthquake data so that the UI is not
            // blocked while the application parses the XML data.
            //
            int storeType = self.type;
            
            if ((storeType == 3) || (storeType == 4)) {
                APLParseOperation *parseOperation = [[APLParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];
                [self.parseQueue addOperation:parseOperation];
            } else {
                HHSJsonParseOperation *parseOperation = [[HHSJsonParseOperation alloc] initWithData: data elementNames:self.parserElementNames store:self];
                [self.parseQueue addOperation:parseOperation];
            }
                
        }
        else {
            NSString *errorString =
            NSLocalizedString(@"HTTP Error", @"Error message displayed when receving a connection error.");
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey : errorString};
            NSError *reportError = [NSError errorWithDomain:@"HTTP"
                                                       code:[httpResponse statusCode]
                                                   userInfo:userInfo];
            [self handleError:reportError];
        }
    }
}

#pragma mark network and xml
- (void)removeObservers {
    
    // we are no longer interested in these notifications:
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:_mAddArticlesNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:_mArticlesErrorNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

#pragma mark handle parse results
- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    [self removeObservers];
    _downloadError = YES;
    [_owner notifyStoreDownloadError:self error:errorMessage];
    _currentlyParsing = NO;
}

- (void)addParseResultsToStore:(NSNotification *)notif {
    
    [self populateStoreWith:[[notif userInfo] valueForKey:_mArticleResultsKey]];
    NSLog(@"%@%@", @"Store updated: ", _mArticleResultsKey);
    [self removeObservers];
    _downloadError = NO;
    [_owner notifyStoreIsReady:self];
}

-(void)parsingDone
{
    NSLog(@"%@%@", @"Store updated: ", _mArticleResultsKey);
    _privateItems = [_tempItems copy];
    [_tempItems removeAllObjects];
    [self saveStore];
    [self removeObservers];
    _downloadError = NO;
    _currentlyParsing = NO;
    
    if (!_parsingInBackgroundFetch){
        //[_owner performSelectorOnMainThread:@selector(notifyStoreIsReady:) withObject:self waitUntilDone:NO];
        [_owner notifyStoreIsReady:self];
    }
}

/**
 Our NSNotification callback from the running NSOperation when a parsing error has occurred
 */
- (void)articlesError:(NSNotification *)notif {
    
    //assert([NSThread isMainThread]);
    //[self.owner handleError:[[notif userInfo] valueForKey:_mArticlesMessageErrorKey]];
}

- (void)addArticlesToList:(NSArray *)articles {
    
    //each subclass must have its own version of this method
}

#pragma mark constants

+(int)HHSArticleStoreTypeSchedules
{
    return 1;
}
+(int)HHSArticleStoreTypeEvents
{
    return 2;
}
+(int)HHSArticleStoreTypeNews
{
    return 3;
}
+(int)HHSArticleStoreTypeDailyAnns
{
    return 4;
}
+(int)HHSArticleStoreTypeLunch
{
    return 5;
}

@end
