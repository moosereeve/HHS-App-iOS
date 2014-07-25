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
#import "APLParseOperation.h"

@interface HHSArticleStore ()

@property (nonatomic) NSMutableDictionary *privateItems;
@property (nonatomic) int type;

@end

@implementation HHSArticleStore

- (instancetype)init
{
    [NSException raise:@"Wrong initializer"
                format:@"Use +[HHSArticleStore initWithType:HHSArticleStore.SCHEDULE]"];
    return nil;
}

- (instancetype)initWithType:(int)type
{
    
    self = [super init];
    if (self) {
        _type = type;
        
        NSString *path = [self articleArchivePath];
        _privateItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        
        //If the array hadn't been saved previously, crete one
        if (!_privateItems) {
            _privateItems = [[NSMutableDictionary alloc] init];
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
    BOOL success = [fileManager removeItemAtPath:path error:&error];
    if (success) {
        NSLog(@"Delete file -:%@ ",path);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
    
    //Returns YES on success
    return [NSKeyedArchiver archiveRootObject:self.privateItems toFile:path];
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
