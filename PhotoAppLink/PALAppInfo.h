//    Copyright (c) 2009 Hendrik Kueck
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

@interface PALAppInfo : NSObject {
    NSString*   appName;
    BOOL        canSend;
    BOOL        canReceive;
    BOOL        installed;
    NSString*   appDescription;
    NSURL*      urlScheme;
    NSString*   bundleID;
    NSString*   appleID;
    NSString*   platform;
    BOOL        freeApp;
    UIImage*    thumbnail;
    NSURL*      thumbnailURL;
}

// Initializer
- (id)initWithPropertyDict:(NSDictionary*)properties;

// the display name of the app
@property (nonatomic, readonly) NSString* appName;
// Flag indicating whether the app is installed on this device
// (only valid for apps that can receive images, NO for other apps)
@property (nonatomic, readonly) BOOL installed;   
// Flag whether the app supports sending images to other apps
@property (nonatomic, readonly) BOOL canSend;
// Flag whether the app supports receiving images
@property (nonatomic, readonly) BOOL canReceive;
// the PhotoAppLink URL used to launch the app
@property (nonatomic, readonly) NSURL* urlScheme;
// a one line description of the app
@property (nonatomic, readonly) NSString* appDescription;
// the app's bundle ID (i.e. "com.apple.imovie")
@property (nonatomic, readonly) NSString* bundleID;
// Apple's app identifier (part of iTunes App Store links, example: "374308914")
@property (nonatomic, readonly) NSString* appleID;
// The device type that the app runs on ("iPhone", "iPad" or "universal")
@property (nonatomic, copy) NSString *platform;
// whether the app is free or paid
@property (nonatomic) BOOL freeApp;
// The image thumbnail (with appropriate scale for the device)
@property (nonatomic, readonly) UIImage* thumbnail;
// URL to thumbnail image
@property (nonatomic, readonly) NSURL* thumbnailURL;

// Link to the app in the app store. 
- (NSURL*)appStoreLink;

@end
