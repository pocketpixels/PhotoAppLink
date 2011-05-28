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

@class PALAppInfo; 

@interface PhotoAppLinkManager : NSObject <UIActionSheetDelegate> {
    NSArray* supportedApps;
    UIImage* imageToSend;
}

// the names of the photo editing apps that are installed on the user's device
// and support receiving images via the photo app link protocol
// Check that this is not nil or empty first
// Then present users this list of apps under a "Send to app" submenu / list. 
@property (nonatomic, readonly) NSArray *destinationAppNames;

// the PALAppInfo objects of the photo editing apps that are installed on the user's device
// and support receiving images via the photo app link protocol
// Check that this is not nil or empty first
// Then present users this list of apps under a "Send to app" submenu / list. 
@property (nonatomic, readonly) NSArray *destinationApps;

// a dictionary of PALAppInfo objects for all supported apps (installed and not)
@property (nonatomic, copy, readonly) NSArray *supportedApps;

// Get the singleton instance
+ (PhotoAppLinkManager*)sharedPhotoAppLinkManager;

// Downloads the latest list of supported apps and their custom URLs in the background
// Call this once immediately after app launch. 
- (void)updateSupportedAppsInBackground;

// Returns the image passed in by the calling app.
// It also clears it off the pasteboard (hence the "pop")
- (UIImage*)popPassedInImage;

// Switches to the app with the given name (should be one of the names in destinationAppNames)
// and passes along the image for further processing.
// If successful, this function will not return but quit the current app and 
- (void)invokeApplication:(NSString*) appName withImage:(UIImage*)image;
- (void)invokeScheme:(NSURL*) urlScheme withImage:(UIImage*)image;

- (UIActionSheet*)actionSheetToSendImage:(UIImage*)image;

@end



@interface PALAppInfo : NSObject {
    NSString*   appName;
    BOOL        canSend;
    BOOL        canReceive;
    BOOL        installed;
    NSString*   appDescription;
    NSURL*      urlScheme;
    NSString*   bundleID;
    NSString*   appleID;
    UIImage*    thumbnail;
    NSURL*      thumbnailURL;
}

// Initializer
- (id)initWithPropertyDict:(NSDictionary*)properties;

// the display name of the app
@property (nonatomic, readonly) NSString* appName;
// Flag indicating whether the app is installed on this device
// (only valid for apps that can receive images)
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
// The image thumbnail (with appropriate scale for the device)
@property (nonatomic, readonly) UIImage* thumbnail;
// URL to thumbnail image
@property (nonatomic, readonly) NSURL* thumbnailURL;

// Link to the app in the app store. 
- (NSURL*)appStoreLink;

@end

