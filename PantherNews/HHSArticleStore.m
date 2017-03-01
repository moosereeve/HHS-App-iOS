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
#import "HHSCategoryVC.h"
#import "HHSHomeViewController.h"
#import "HHSXmlParseOperation.h"
#import "HHSJsonParseOperation.h"

@interface HHSArticleStore ()

@property (nonatomic) NSMutableDictionary *privateItems;
@property (nonatomic) NSMutableDictionary *tempItems;
@property (nonatomic) int type;
@property (nonatomic) BOOL triggersNotification;
@property (nonatomic) BOOL sortNowToFuture;

@property (nonatomic) NSOperationQueue *parseQueue;
@property BOOL parsingInBackgroundFetch;
@property BOOL currentlyParsing;

//@property (nonatomic) NSArray *owners;
@property (nonatomic, weak) HHSMainViewController *owner;

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
       triggersNotification:(BOOL)triggersNotification
                      owner:(HHSMainViewController *)owner
{
    
    self = [super init];
    if (self) {
        _type = type;
        _owner = owner;
        _parserElementNames = parserNames;
        _feedUrlString = feedUrlString;
        _feedUrl = [[NSURL alloc] initWithString:self.feedUrlString];

        _sortNowToFuture = sortOrder;
        _triggersNotification = triggersNotification;
        _downloadError = NO;
        _currentlyParsing = NO;
        
        _mAddArticlesNotificationName = [NSString stringWithFormat:@"%@%i", kAddArticlesNotificationName, [self getType]];
        _mArticleResultsKey = [NSString stringWithFormat:@"%@%i", kArticleResultsKey, [self getType]];
        _mArticlesErrorNotificationName = [NSString stringWithFormat:@"%@%i", kArticlesErrorNotificationName, [self getType]];
        _mArticlesMessageErrorKey = [NSString stringWithFormat:@"%@%i", kArticlesMessageErrorKey, [self getType]];
        
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
    NSArray *newArticles = [self.privateItems allValues] ;
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:_sortNowToFuture];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    NSArray *sortedArray = [newArticles sortedArrayUsingDescriptors:descriptors];
    
    return sortedArray;
}

- (HHSArticle *)newArticle
{
    HHSArticle *item = [[HHSArticle alloc] init];
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
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
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
        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *lastDateComp = [cal components:(NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:lastDate];
        int lastYear =   (int)[lastDateComp year];
        int lastMonth =  (int)[lastDateComp month];
        int lastDay =    (int)[lastDateComp day];
        int lastHour =   13; //[lastDateComp hour];
        int lastMinute = 35; //[lastDateComp minute];
        
        NSDate *today = [[NSDate alloc] init];
        NSDateComponents *todayComp = [cal components:(NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:today];
        int todayYear =   (int)[todayComp year];
        int todayMonth =  (int)[todayComp month];
        int todayDay =    (int)[todayComp day];
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
    
    NSURLRequest *articleURLRequest =
    [NSURLRequest requestWithURL:self.feedUrl];
    
    [NSURLConnection sendAsynchronousRequest:articleURLRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               [self handleUrlConnectCompletion:response data:data error:error];
                               
                           }];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

-(void)getArticlesInBackground{
    _tempItems = [[NSMutableDictionary alloc] init];
    _parsingInBackgroundFetch = YES;
    
    NSURLRequest *articleURLRequest = [NSURLRequest requestWithURL:self.feedUrl];
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:articleURLRequest returningResponse:&response error:&error];
    
    [self handleUrlConnectCompletion:response data:data error:error];
}

-(void)handleUrlConnectCompletion:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error != nil) {
        [self handleError:error];
    }
    else {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ((([httpResponse statusCode]/100) == 2) ) {
            [self startParse:data];
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

-(void)startParse:(NSData *)data
{
    self.parseQueue = [NSOperationQueue new];
    NSOperation *parseOperation = [self setupParse:data];
    [self.parseQueue addOperation:parseOperation];
}

-(id)setupParse:(NSData *)data
{
    //can be overridden in subclass
    HHSXmlParseOperation *parseOperation = [[HHSXmlParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];
    /*HHSJsonParseOperation *parseOperation = [[HHSJsonParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];*/
    return parseOperation;
}

#pragma mark network and xml

#pragma mark handle parse results
- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    _downloadError = YES;
    [_owner notifyStoreDownloadError:self error:errorMessage];
    _currentlyParsing = NO;
}

-(void)parsingDone
{
    NSLog(@"%@%@", @"Store updated: ", _mArticleResultsKey);
    _privateItems = [_tempItems copy];
    [_tempItems removeAllObjects];
    [self saveStore];
    
    _downloadError = NO;
    _currentlyParsing = NO;
    
    if (self.triggersNotification) {
        NSArray *articles = [self allArticles];
        if ([articles count]>0) {
            HHSArticle *article = articles[0];
            NSString *newNewsKey = article.articleKey;
            if ([newNewsKey isEqualToString:_formerNewsKey]) {
                [self sendNotification:article];
                NSLog(@"Notification sent");
            }
            //TODO: this is a debug command
            //[self sendNotification:article];
        }
    }
    
    if (!_parsingInBackgroundFetch){
        //[_owner performSelectorOnMainThread:@selector(notifyStoreIsReady:) withObject:self waitUntilDone:NO];
        [_owner notifyStoreIsReady:self];
    } else {
    }
}

-(void) sendNotification:(HHSArticle *)article
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) {
        return;
    }
    
    NSDate *date = [[NSDate alloc] init];
    
    localNotif.fireDate = date;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = article.title;
    localNotif.alertAction = @"Read article";
    localNotif.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] +1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
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

+(int)HHSArticleStoreTypeSchedules { return 1; }
+(int)HHSArticleStoreTypeEvents { return 2; }
+(int)HHSArticleStoreTypeNews { return 3; }
+(int)HHSArticleStoreTypeDailyAnns { return 4; }
+(int)HHSArticleStoreTypeLunch { return 5; }

@end
