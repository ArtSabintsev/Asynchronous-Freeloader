//
//  AsynchronousFreeloader.m
//  Asynchronous Freeloader
//
//  Created by Arthur Ariel Sabintsev on 5/7/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import "AsynchronousFreeloader.h"

@interface AsynchronousFreeloader ()

+ (void)presentPlaceholderView:(UIView*)placeholderView                     // Present placeholderView while data is loaded from disk/web
                   inImageView:(UIImageView*)imageView;

+ (void)removePlaceholderView:(UIView*)placeholderView                      // Remove placeholderView after data is loaded from disk/web
                fromImageView:(UIImageView*)imageView;

+ (NSMutableDictionary*)createReferenceToCache;                             // Create local instance of NSMutableDictionary

+ (BOOL)doesImageWithName:(NSString*)name                                   // Check if image exists in cache and on device (determines if HTTP request needs to be performed)
                   exist:(NSMutableDictionary*)cache;                                          

+ (void)saveImageWithName:(NSString*)name                                   // Save data from asynchronous response to tmp directory on device
                 fromData:(NSData*)data;                    

+ (void)successfulResponseForImageView:(UIImageView*)imageView              // Asynchronous request succeeded
                              withData:(NSData *)data
                              fromLink:(NSString*)link;

+ (void)failedResponseForImageView:(UIImageView*)imageView;                 // Asynchronous request failed

@end

@implementation AsynchronousFreeloader

#pragma mark - Public Methods
+ (void)loadImageFromLink:(NSString *)link forImageView:(UIImageView *)imageView withPlaceholderView:(UIView *)placeholderView
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Present placeholderView
        [self presentPlaceholderView:placeholderView inImageView:imageView];
        
        // Reference Cache (e.g., NSMutableDictionary)
        NSMutableDictionary *cache = [AsynchronousFreeloader createReferenceToCache];
        
        // Check if image exists in cache and on disk
        BOOL imageExists = [AsynchronousFreeloader doesImageWithName:link exist:cache];
        
        if ( imageExists ) {    
            
            // Load image from disk
            imageView.image = [UIImage imageWithContentsOfFile:[cache objectForKey:link]];
            
            // Remove placeholder
            [self removePlaceholderView:placeholderView fromImageView:imageView];

            
        } else {                
            
            // Load image from web via asychronous request
            NSURL *url = [NSURL URLWithString:link];
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                
                if ([data length] > 0 && error == nil) {    // Successful asynchronous response
                    
                    [AsynchronousFreeloader successfulResponseForImageView:imageView withData:data fromLink:link];
                    
                } else {                                    // Failed asynchronous response
                    
                    [AsynchronousFreeloader failedResponseForImageView:imageView];
                    
                }
                
                // Remove placeholder
                [self removePlaceholderView:placeholderView fromImageView:imageView];
                
            }];
            
        }

        
    });
    
}

#pragma mark - Private Methods
+ (void)presentPlaceholderView:(UIView *)placeholderView inImageView:(UIImageView *)imageView
{
    dispatch_async(dispatch_get_main_queue(), ^{
   
        if ( nil == placeholderView ) {     // Add UIActivityIndicatorView placeholder
            

                
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                [activityIndicator setFrame:imageView.frame]; 
                [imageView addSubview:activityIndicator]; 
                [activityIndicator startAnimating];
                
            
        } else {                            // Add user-defined placeholder
            
            [imageView addSubview:placeholderView];
            
        }
        
    });
    
}

+ (void)removePlaceholderView:(UIView *)placeholderView fromImageView:(UIImageView *)imageView
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
            
        if ( nil == placeholderView ) {     // Remove UIActivityIndicatorView placeholder
            
            for ( UIActivityIndicatorView *view in [imageView subviews] ) {
                
                [view stopAnimating];
                [view removeFromSuperview];
            }
            
        } else {                            // Remove user-defined placeholder 
            
            [placeholderView removeFromSuperview];
            
        }
    
    });

}
                   
+ (NSMutableDictionary*)createReferenceToCache
{
    
    NSMutableDictionary *cache = [NSMutableDictionary dictionary];
    
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:AsynchronousFreeloaderCache] ) {
        
        // Add stored cache from NSUserDefaults
        [cache setDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:AsynchronousFreeloaderCache]];
        
        // Empty cache if there are too many entries
        if  ( AsynchronousFreeloaderCacheSize >= [cache count] ) {
            
            [cache removeAllObjects];
            [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
            [[NSUserDefaults standardUserDefaults] synchronize];
         
        }
         
        
    }
    
    return cache;
}

+ (BOOL)doesImageWithName:(NSString *)name exist:(NSMutableDictionary *)cache
{
    
    BOOL imageExists;
    
    // Check if image reference exists in cache
    BOOL cacheReferenceExists = ( [cache objectForKey:name] ) ? YES : NO;
    
    // Check if image exists at referenced path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL pathReferenceExists = [fileManager fileExistsAtPath:[cache objectForKey:name]];
    
    if ( cacheReferenceExists && pathReferenceExists ) {            // If image exists in cache and on device
        
        imageExists = YES;
    
    } else if ( cacheReferenceExists && !pathReferenceExists ) {    // If image exists in cache, but doesn't exist on device
        
        // Remove image-reference from cache and update NSUserDefaults
        [cache removeObjectForKey:name];
        [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    
    // Save path to cache
    [cache setObject:path forKey:name];
    
    // Save cache to NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:cache forKey:AsynchronousFreeloaderCache];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (void)successfulResponseForImageView:(UIImageView *)imageView withData:(NSData *)data fromLink:(NSString *)link
{
    
    [AsynchronousFreeloader saveImageWithName:link fromData:data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Remove UIActivityIndicatorView
        for ( UIActivityIndicatorView *view in [imageView subviews] ) {
            
            [view stopAnimating];
            [view removeFromSuperview];
        }
        
        // Update imageView on Main Thread
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.image = [UIImage imageWithData:data];
    
    });
    
}

+ (void)failedResponseForImageView:(UIImageView *)imageView
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Custom failed response
        
    });
    
}

@end