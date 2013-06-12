//
//  AsynchronousFreeloader.m
//  Asynchronous Freeloader
//
//  Created by Arthur Ariel Sabintsev on 5/7/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import "AsynchronousFreeloader.h"

@interface AsynchronousFreeloader ()

+ (void)presentPlaceholder:(UIImage *)placeholder                            // Present placeholder while data is loaded from disk/web
               inImageView:(UIImageView *)imageView;

+ (void)removeActivityIndicator:(UIImageView *)imageView;                    // Remove Activity Indicator

+ (NSMutableDictionary *)createReferenceToCache;                             // Create local instance of NSMutableDictionary

+ (BOOL)doesImageWithName:(NSString *)name                                   // Check if image exists in cache and on device (determines if HTTP request needs to be performed)
                   existInCache:(NSMutableDictionary *)cache;                                          

+ (void)saveImageWithName:(NSString *)name                                   // Save data from asynchronous response to tmp directory on device
                 fromData:(NSData *)data;                    

+ (void)resaveImageWithName:(NSString *)name                                 // Change position of image in cache to preserve newness 
                    inCache:(NSMutableDictionary *)cache;                         

+ (void)performGarbageCollection;                                            // Clear cache if number of entries exceeds amount defined by 'AsynchronousFreeloaderCache'

+ (void)successfulResponseForImageView:(UIImageView *)imageView              // Asynchronous request succeeded
                              withData:(NSData *)data
                              fromLink:(NSString *)link
                        andContentMode:(UIViewContentMode)contentMode;

+ (void)failedResponseForImageView:(UIImageView *)imageView;                 // Asynchronous request failed

@end

@implementation AsynchronousFreeloader

#pragma mark - Public Methods
+ (void)loadImageFromLink:(NSString *)link
             forImageView:(UIImageView *)imageView
          withPlaceholder:(UIImage *)placeholder
           andContentMode:(UIViewContentMode)contentMode
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Reference Cache (e.g., NSMutableDictionary)
        NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
        
        // Check if image exists in cache and on disk
        BOOL imageExists = [AsynchronousFreeloader doesImageWithName:link existInCache:cache];
        
        if ( imageExists ) {    
            
            // Load image from disk
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.contentMode = contentMode;
                imageView.clipsToBounds = YES;
                imageView.image = [UIImage imageWithContentsOfFile:[[cache objectForKey:AsynchronousFreeloaderCachePaths] valueForKey:link]];
            });
                           
            
        } else {                
            
            // Present placeholderView
            [self presentPlaceholder:placeholder inImageView:imageView];
            
            // Load image from web via asychronous request
            NSURL *url = [NSURL URLWithString:link];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if ([data length] > 0 && error == nil) {    // Successful asynchronous response
                    
                    [AsynchronousFreeloader successfulResponseForImageView:imageView withData:data fromLink:link andContentMode:contentMode];
                    
                } else {                                    // Failed asynchronous response
                    
                    [AsynchronousFreeloader failedResponseForImageView:imageView];
                    
                }
                
                // Remove activity indicator after success or failure. 
                [self removeActivityIndicator:imageView];
            }];
            
        }

        
    });
    
}

+ (void)removeImageFromCache:(NSString *)link
{

   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
       
       // Save path to pathsDictionary of cache
       NSMutableDictionary *pathsDictionary = [NSMutableDictionary dictionaryWithDictionary:[cache objectForKey:link]];
       [pathsDictionary removeObjectForKey:link];
       
       // Save name to namesArray of cache (used to retain position)
       NSMutableArray *namesArray = [NSMutableArray arrayWithArray:[cache objectForKey:link]];
       [namesArray removeObject:link];
       
       // Save pathsDictionary and namesArray to cache
       [cache setObject:pathsDictionary forKey:AsynchronousFreeloaderCachePaths];
       [cache setObject:namesArray forKey:AsynchronousFreeloaderCacheNames];
   
       // Save cache to NSUserDefaults
       [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
       [[NSUserDefaults standardUserDefaults] synchronize];
       
   });

}

+ (void)removeAllImages
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
        
        // Save cache to NSUserDefaults
        [cache removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
        [[NSUserDefaults standardUserDefaults] synchronize];

    });
    
}

#pragma mark - Private Methods
+ (void)presentPlaceholder:(UIImage *)placeholder inImageView:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setFrame:imageView.frame];
        [activityIndicator setCenter:CGPointMake(imageView.frame.size.width/2.0f, imageView.frame.size.height/2.0f)];
        [imageView addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        if (placeholder) {                           // Add user-defined placeholder
            [imageView setImage:placeholder];
        }
    });
    
}


+ (void)removeActivityIndicator:(UIImageView *)imageView
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIActivityIndicatorView *view in [imageView subviews]) {
            [view stopAnimating];
            [view removeFromSuperview];
        }
    });
}

+ (NSMutableDictionary*)createReferenceToCache
{
    
    // Create Cache
    NSMutableDictionary *cache = [NSMutableDictionary dictionary];
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:AsynchronousFreeloaderCache] ) {
        
        // Add stored cache from NSUserDefaults
        [cache setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:AsynchronousFreeloaderCache]];
        
    } else {
        
        [cache setObject:[NSMutableDictionary dictionary] forKey:AsynchronousFreeloaderCachePaths];
        [cache setObject:[NSMutableArray array] forKey:AsynchronousFreeloaderCacheNames];
        [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return cache;
}

+ (BOOL)doesImageWithName:(NSString *)name existInCache:(NSMutableDictionary *)cache
{
    
    BOOL imageExists = NO;
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:[cache objectForKey:AsynchronousFreeloaderCacheNames]];
    NSMutableDictionary *pathsDictionary = [NSMutableDictionary dictionaryWithDictionary:[cache objectForKey:AsynchronousFreeloaderCachePaths]];
  
    NSString *imagePath = [pathsDictionary valueForKey:name];
    

    // Check if image reference exists in cache
    BOOL cacheReferenceExists = ( [namesArray containsObject:name] ) ? YES : NO;
    
    // Check if image exists at referenced path
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL pathReferenceExists = [fileManager fileExistsAtPath:imagePath];
    
    if ( cacheReferenceExists && pathReferenceExists ) {            // If image exists in cache and on device
        
        // Change position of image in cache and update NSUserDefaults
        [AsynchronousFreeloader resaveImageWithName:name inCache:cache];
        
        imageExists = YES;
        
    
    } else if ( cacheReferenceExists && !pathReferenceExists ) {    // If image exists in cache, but doesn't exist on device
        
        // Remove reference to image from cache and update NSUserDefaults
        [AsynchronousFreeloader removeImageFromCache:name];
        
        imageExists = NO;
        
    } else {                                                        // If image doesn't exists in cache, nor on the device
        
        imageExists = NO;
        
    }
    
    return imageExists;
}

+ (void)saveImageWithName:(NSString *)name fromData:(NSData *)data
{
    
    NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
    
    // Save image to disk with URL-based fileName
    NSString *filename = [NSString stringWithFormat:@"%@", name];
    filename = [filename stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), filename];
    [data writeToFile:path atomically:YES];
    
    // Save path to pathsDictionary of cache
    NSMutableDictionary *pathsDictionary = [NSMutableDictionary dictionaryWithDictionary:[cache objectForKey:AsynchronousFreeloaderCachePaths]];
    [pathsDictionary setObject:path forKey:name];
    
    // Save name to namesArray of cache (used to retain position)
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:[cache objectForKey:AsynchronousFreeloaderCacheNames]];
    [namesArray addObject:name];

    // Save pathsDictionary and namesArray to cache
    [cache setObject:pathsDictionary forKey:AsynchronousFreeloaderCachePaths];
    [cache setObject:namesArray forKey:AsynchronousFreeloaderCacheNames];
    
    // Save cache to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void)resaveImageWithName:(NSString *)name inCache:(NSMutableDictionary *)cache
{
    // Create reference to  namesArray and change location of image
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:[cache objectForKey:AsynchronousFreeloaderCacheNames]];

    [namesArray removeObject:name];
    [namesArray addObject:name];
    
    // Save namesArray in cache
    [cache setObject:namesArray forKey:AsynchronousFreeloaderCacheNames];
    
    // Save cache to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)performGarbageCollection
{
    
    NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
    
    // Reference pathsDictionary and namesArray
    NSMutableDictionary *pathsDictionary = [NSMutableDictionary dictionaryWithDictionary:[cache objectForKey:AsynchronousFreeloaderCachePaths]];
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:[cache objectForKey:AsynchronousFreeloaderCacheNames]];
    
    // Empty cache if there are too many entries
    if  ( [namesArray count] >= AsynchronousFreeloaderCacheSize ) {
        
        NSUInteger limitExcessionAmount = (NSUInteger)fabs([namesArray count] - AsynchronousFreeloaderCacheSize);
        
        while (limitExcessionAmount > 0) {
            
            [pathsDictionary removeObjectForKey:[namesArray objectAtIndex:0]];
            [namesArray removeObjectAtIndex:0];
            
            limitExcessionAmount--;
            
        }

    }
    
    // Save pathsDictionary and namesArray to cache
    [cache setObject:pathsDictionary forKey:AsynchronousFreeloaderCachePaths];
    [cache setObject:namesArray forKey:AsynchronousFreeloaderCacheNames];
    
    // Save cache to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void)successfulResponseForImageView:(UIImageView *)imageView 
                              withData:(NSData *)data 
                              fromLink:(NSString *)link
                        andContentMode:(UIViewContentMode)contentMode
{
    
    [AsynchronousFreeloader saveImageWithName:link fromData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Update imageView on Main Thread
        imageView.contentMode = contentMode;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageWithData:data];
    
    });
    
    [AsynchronousFreeloader performGarbageCollection];
    
}

+ (void)failedResponseForImageView:(UIImageView *)imageView
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Custom failed response
        
    });
    
}

@end