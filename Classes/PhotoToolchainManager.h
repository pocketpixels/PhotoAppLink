//
//  PhotoToolchainManager.h
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright 2009 Pocket Pixels Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoToolchainManager : NSObject {
    NSMutableDictionary* installedAppsURLSchemes; 
}

// the names of the photo editing apps that are installed on the user's device
// and support the photo app exchange scheme
@property (nonatomic, readonly) NSArray *destinationAppNames;

// Get the singleton instance
// Note that this will return nil on pre-3.0 OS versions. 
// So test for nil before using it!
+ (PhotoToolchainManager*) sharedPhotoToolchainManager;

// Switches to the app with the given name (should be one of the names in installedDestinationApps)
// and passes along the image for further processing.
// If successful, this function will not return but quit the current app and 
-(void) invokeApplication:(NSString*) appName withImage:(UIImage*) image;

// Returns the image passed in by the calling app.
// It also clears it off the pasteboard (hence the "pop")
-(UIImage*) popPassedInImage;


@end
