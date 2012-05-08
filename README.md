# Asynchronous Freeloader

## Multithreaded Asynchronous Image Downloader

### About
**Asynchronous Freeloader** is an asynchronous image downloader that utilizes Grand Central Dispatch and disk caching.

### Features:
- iOS 5+ Compatible
- ARC Compliant
- Image Scaling
- Temporary Disk Caching
- Support for placeholder/loading UIView object
- Multithreaded Image Downloading

### Installation Instructions:

- Copy the 'Asynchronous Freeloader' folder into your Xcode project. The following files will be added:
	1. AsynchronousFreeloader.h
	1. AsynchronousFreeloader.m
	
- Follow the instructions below:

<pre>
 - Add #import "AsynchronousFreeloader.h" to your class(es).
 
 	- Use the following line of code to download your image:
 
 	[AsynchronusFreeloader loadImageFromLink:(NSString *)link 
 								forImageView:(UIImageView *)imageView
 						 withPlaceholderView:(UIView *)placeholderView];
 
	- The third parameter, 'placeholderView' is optional. 
	- A large white UIActivityIndicatorView will be used if you pass 'nil' to placeholderView.
</pre>

- Caching
	- NSUserDefaults are used to store an NSMutableDictionary.
	- Dictionary Ojects: Paths to images stored in a temporary folder on the disk. 
	- Dictionary Keys: Download URLs for images.
	- Cache is emptied if there are too many entires.
		- This condition is defined by the *AsynchronousFreeloaderCacheSize* macro in **AsynchronousFreeloader.h**
		- The default value is **200**.
	
- Failed Response
	- There's a method named **failedResponseForImageView:** that is empty by default.
	- Place your error handling code in there.

##  Release Notes (v1.0.0):
- Initial Release

### Recognition:
- Created for [Shelby.tv](http://www.shelby.tv) at Cyberdyne Systems NYC

Best,

[Arthur Ariel Sabintsev](http://www.sabintsev.com)  