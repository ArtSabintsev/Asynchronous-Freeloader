# Asynchronous Freeloader

## Multithreaded Asynchronous Image Downloader

### About
**Asynchronous Freeloader** is an asynchronous image downloader that utilizes Grand Central Dispatch and disk caching.

### Features:
- iOS 5+ Compatible
- ARC Compliant
- Image Scaling
- Disk Caching
- Support for placeholder/loading UIView object
- Multithreaded Image Downloading
- Automated Garbage Collections 

### Instructions:

#### Files
- Copy the 'Asynchronous Freeloader' folder into your Xcode project. The following files will be added:
	1. AsynchronousFreeloader.h
	1. AsynchronousFreeloader.m

#### Incorporating AsynchronousFreeloader to Existing Project
- Import **AsynchronousFreeloader.h** to your classes.
- Inspect **AsynchronousFreeloader.h** for heavily commented public methods.

#### Fetch Images
<pre>

+ (void)loadImageFromLink:(NSString *)link 
             forImageView:(UIImageView *)imageView 
      	  withPlaceholder:(UIImage *)placeholder
           andContentMode:(UIViewContentMode)contentMode;

</pre>
The parameters:

- ```link```: An NSString of the image's URL
- ```imageView```: The imageView in which to load the fetched image
- ```placeholder```: The image to display while fetching the image. A large, white UIActivityIndicatorView will be displayed on top of the image while it's loading. This even works when you pass ```nil``` to this parameter.
- ```contentMode```: Allows you to set the scale/fill of the downloaded image


#### Caching
- NSUserDefaults are used to store an NSMutableDictionary.
- The NSMutableDictionary contains two objects:
	1. *pathsDictionary:* NSMutableDictionary of paths to images stored in a temporary folder on the disk. 
	1. *namesArray:* NSMutableArray of URLS to images, which are used as keys throughout the class. 
- Cache is emptied if number of entries exceeds a user-defined limit
	- This condition is defined by the *AsynchronousFreeloaderCacheSize* macro in **AsynchronousFreeloader.h**.
	- The default value is **1000**.
- Failed Response
	- Place your error handling code in **failedResponseForImageView:** 
	- The method is empty by default.

###  Release Notes (v1.2.1):
-  Removed placeholderView (UIImageView) in favor of placeholder (UIImage).

### Contributions:
- [Keren Pinkas](http://www.github.com/kepsolution) (v1.2.1)

### Recognition:
Created by [Arthur Ariel Sabintsev](http://www.sabintsev.com)  

### License
The MIT License (MIT)
Copyright (c) 2012 Arthur Ariel Sabintsev

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.