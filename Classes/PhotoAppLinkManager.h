//
//  PhotoAppLinkManager.h
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright 2009 Pocket Pixels Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoAppLinkManager : NSObject {
    NSMutableDictionary* installedAppsURLSchemes; 
    NSString* previousAppBundleID;
    BOOL didReturnFromApp;
}

// the names of the photo editing apps that are installed on the user's device
// and support the photo app exchange scheme
@property (nonatomic, readonly) NSArray *destinationAppNames;

// Get the singleton instance
// Note that this will return nil on pre-3.0 OS versions. 
// So test for nil before using it!
+ (PhotoAppLinkManager*)sharedPhotoAppLinkManager;

// This method should be called from the app delegate with the dictionary 
// passed to the didFinishLaunchingWithOptions: method.
// This is only neccessary for implementing the "return to previous app" 
// functionality (optional).
- (void)parseAppLaunchOptions:(NSDictionary*)launchOptions;

// Returns the image passed in by the calling app.
// It also clears it off the pasteboard (hence the "pop")
- (UIImage*)popPassedInImage;

// Switches to the app with the given name (should be one of the names in installedDestinationApps)
// and passes along the image for further processing.
// If successful, this function will not return but quit the current app and 
- (void)invokeApplication:(NSString*) appName withImage:(UIImage*)image;

// Check whether it is possible to return to the previous photo editing app
- (BOOL)canReturnToPreviousApp;

// Return to the previous photo editing app, passing along the edited image
// Always call canReturnToPreviousApp to check if this is possible first.
- (void)returnToPreviousAppWithImage:(UIImage*)image;

@end

