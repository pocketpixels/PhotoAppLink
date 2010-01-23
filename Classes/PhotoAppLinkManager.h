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

@interface PhotoAppLinkManager : NSObject {
    NSMutableDictionary* installedAppsURLSchemes; 
}

// the names of the photo editing apps that are installed on the user's device
// and support the photo app exchange scheme
// Check that this is not nil or empty first
// Then present users this list of apps under a "Send to app" submenu / list. 
@property (nonatomic, readonly) NSArray *destinationAppNames;

// Get the singleton instance
// Note that this will return nil on pre-3.0 OS versions. 
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

@end

