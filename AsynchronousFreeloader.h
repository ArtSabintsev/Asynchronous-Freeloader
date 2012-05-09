//
//  AsynchronousFreeloader.h
//  Asynchronous Freeloader
//
//  Created by Arthur Ariel Sabintsev on 5/7/12.
//  Copyright (c) 2012 ArtSabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Software Author Customized Definitions
#define AsynchronousFreeloaderCache         @"Aynchronous Freeloader Cache"
#define AsynchronousFreeloaderCachePaths    @"Aynchronous Freeloader Cache Path"
#define AsynchronousFreeloaderCacheNames    @"Aynchronous Freeloader Cache Name"

#pragma mark - User Customized Definitions
#define AsynchronousFreeloaderCacheSize     100

@interface AsynchronousFreeloader : NSObject

/* 

 Asynchronously load image from 'link' and set it in 'imageView'. 
 Optionally, you may add a placeholderView to be displayed while your image is being fetched.
 If you pass 'nil' tp placeholderView, a large white UIActivityIndicatorView will be used.
 
 */

+ (void)loadImageFromLink:(NSString *)link 
             forImageView:(UIImageView *)imageView 
      withPlaceholderView:(UIView*)placeholderView;       

// Remove an image from the cache (images use links as dictionary keys)
+ (void)removeImageFromCache:(NSString*)link;

// Empty the cache
+ (void)removeAllImages;

@end