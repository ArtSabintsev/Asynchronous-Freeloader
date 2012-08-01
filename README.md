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

####  Caching
- NSUserDefaults are used to store an NSMutableDictionary.
- The NSMutableDictionary contains two objects:
	1. *pathsDictionary:* NSMutableDictionary of paths to images stored in a temporary folder on the disk. 
	1. *namesArray:* NSMutableArray of URLS to images, which are used as keys throughout the class. 
- Cache is emptied if number of entries exceeds a user-defined limit
	- This condition is defined by the *AsynchronousFreeloaderCacheSize* macro in **AsynchronousFreeloader.h**.
	- The default value is **100**.
- Failed Response
	- Place your error handling code in **failedResponseForImageView:** 
	- The method is empty by default.

###  Release Notes (v1.1.1):
- Images now redrawn correctly if they're loaded from the cache

###  Previous Release Notes
#### v1.1.0
- Added automated garbage collection for cache

#### v1.0.0:
- Initial Release

### Recognition:
- Created for [Shelby.tv](http://www.shelby.tv) at Cyberdyne Systems NYC

Best,

[Arthur Ariel Sabintsev](http://www.sabintsev.com)  