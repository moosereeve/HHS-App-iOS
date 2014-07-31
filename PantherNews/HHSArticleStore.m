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

@interface HHSArticleStore ()

@property (nonatomic) NSOperationQueue *parseQueue;
@property (nonatomic) NSMutableDictionary *privateItems;
@property (nonatomic) int type;
@property (nonatomic, strong) NSString *feedUrlString;
@property (nonatomic) NSDictionary *parserElementNames;
@property (nonatomic) NSArray *owners;

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
                     owners:(NSArray *)owners
{
    
    self = [super init];
    if (self) {
        _type = type;
        _owners = owners;
        _parserElementNames = parserNames;
        _feedUrlString = feedUrlString;
        
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

- (NSArray *)allArticles
{
    return [self.privateItems allValues];
}

- (HHSArticle *)createItem
{
    HHSArticle *item = [[HHSArticle alloc] init];
    
    //[self.privateItems  addObject:item];
    self.privateItems[item.articleKey] = item;
    
    return item;
}

- (void)registerArticleInStore:(HHSArticle *)article
{
    self.privateItems[article.articleKey] = article;
}

-(void)replaceAllArticlesWith:(NSArray *)articleList
{
    //NSDictionary *backupOfItems = [[NSDictionary alloc] initWithDictionary:self.privateItems copyItems:YES];
    
    [self.privateItems removeAllObjects];
    for (HHSArticle *article in articleList) {
        [self registerArticleInStore:article];
    }
    
    [self saveChanges];
    
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

-(void)removeAllItems
{
    for (HHSArticle *article in self.privateItems) {
        [self.privateItems removeObjectForKey:article.articleKey];
    
        NSString *key = article.articleKey;
        [[HHSImageStore sharedStore] deleteImageForKey:key];
    }
    }

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

- (BOOL)saveChanges
{
    NSString *path = self.articleArchivePath;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    [fileManager removeItemAtPath:path error:&error];
    
    //Returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
}

-(void)getArticlesFromFeed
{
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
                                   if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
                                       
                                       // Update the UI and start parsing the data,
                                       // Spawn an NSOperation to parse the earthquake data so that the UI is not
                                       // blocked while the application parses the XML data.
                                       //
                                       APLParseOperation *parseOperation = [[APLParseOperation alloc] initWithData:data elementNames:self.parserElementNames store:self];
                                       [self.parseQueue addOperation:parseOperation];
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
                           }];
    
    // Start the status bar network activity indicator.
    // We'll turn it off when the connection finishes or experiences an error.
    //
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    self.parseQueue = [NSOperationQueue new];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addArticles:)
                                                 name:_mAddArticlesNotificationName object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(articlesError:)
                                                 name:_mArticlesErrorNotificationName object:nil];
}

#pragma mark network and xml
- (void)dealloc {
    
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

/**
 Handle errors in the download by showing an alert to the user. This is a very simple way of handling the error, partly because this application does not have any offline functionality for the user. Most real applications should handle the error in a less obtrusive way and provide offline functionality to the user.
 */
- (void)handleError:(NSError *)error {
    
    NSString *errorMessage = [error localizedDescription];
    NSString *alertTitle = NSLocalizedString(@"Error", @"Title for alert displayed when download or parse error occurs.");
    NSString *okTitle = NSLocalizedString(@"OK ", @"OK Title for alert displayed when download or parse error occurs.");
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle message:errorMessage delegate:nil cancelButtonTitle:okTitle otherButtonTitles:nil];
    [alertView show];
    HHSTableViewController *tvc = self.owners[0];
    [tvc.delegate refreshDone:_type ];
}

/**
 Our NSNotification callback from the running NSOperation to add the earthquakes
 */
- (void)addArticles:(NSNotification *)notif {
    
    [self replaceAllArticlesWith:[[notif userInfo] valueForKey:_mArticleResultsKey]];

    assert([NSThread isMainThread]);
    HHSTableViewController *tvc = _owners[0];
    //HHSHomeViewController *homeVC = _owners[1];
    
    [tvc retrieveArticles];
    //[homeVC fillAll];
    //[_activityView stopAnimating];
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


-(int)getType
{
    return self.type;
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

@end
