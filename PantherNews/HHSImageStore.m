//
//  HHSImageStore.m
//  PantherNews
//
//  Created by Thomas Reeve on 6/19/14.
//  Copyright (c) 2014 Holliston High School. All rights reserved.
//

#import "HHSImageStore.h"
#import "HHSArticle.h"

@interface HHSImageStore ()

@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation HHSImageStore

+ (instancetype)sharedStore {
    static HHSImageStore *sharedStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    return sharedStore;
}

//No one should call init
- (instancetype)init
{
    [NSException raise:@"Singleton" format:@"Use +[HHSImageStore sharedStore]"];
    return nil;
}

//Secret designated initializer
- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(clearCache:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    self.dictionary[key] = image;
    
    //Create full path for image
    NSString *imagePath = [self imagePathForKey:key];
    
    //Turn image into JPEG data
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    
    //Write it to full path
    [data writeToFile:imagePath atomically:YES];
}

//ONLY call setImageWithUrlString from within an asynchronous thread
//(like from within APLParserOperation)
- (void)setImageWithUrlString:(NSString *)urlString forArticle:(HHSArticle *)article
{
    NSString *key = article.articleKey;
    
    NSURL *url = [NSURL URLWithString:urlString];
    UIImage *image;

    UIImage *testImage = [[HHSImageStore sharedStore] imageForKey:key];
    
    if (!testImage) {
        image = [UIImage imageWithData: [NSData dataWithContentsOfURL:url]];
        if (image) {
            [self setImage:image forKey:key];
            [article setThumbnailFromImage:image];
        }
    } else{
        image = testImage;
        [article setThumbnailFromImage:image];

    }
    
    
    
}


- (UIImage *)imageForKey:(NSString *)key
{
    //If possible, get it from the dictionary
    UIImage *result = self.dictionary[key];
    
    if (!result) {
        NSString *imagePath = [self imagePathForKey:key];
        
        //Create UIImage object from file;
        result = [UIImage imageWithContentsOfFile:imagePath];
        
        //If we found an image on the file system, place it into the cache
        if (result) {
            self.dictionary[key] = result;
        }
    }
    
    return result;
    
}

- (void)deleteImageForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [self.dictionary removeObjectForKey:key];
    
    NSString *imagePath = [self imagePathForKey:key];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
}

- (NSString *)imagePathForKey:(NSString *)key
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        //ALog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}

-(void)clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", (int)[self.dictionary count]);
    [self.dictionary removeAllObjects];
}

@end
