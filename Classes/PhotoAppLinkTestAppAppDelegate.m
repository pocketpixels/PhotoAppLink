//
//  PhotoAppLinkTestAppAppDelegate.m
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import "PhotoAppLinkTestAppAppDelegate.h"
#import "PhotoAppLinkTestAppViewController.h"
#import "PhotoAppLinkManager.h"

@implementation PhotoAppLinkTestAppAppDelegate

@synthesize rootViewController;
@synthesize window;
@synthesize navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // Simply accessing the applink manager here triggers a background update of the list of supported apps
    // (if necessary). So do this first thing. 
    PhotoAppLinkManager* applink = [PhotoAppLinkManager sharedPhotoAppLinkManager];

    // If you are not sure about your app's bundle ID, this prints it:
    // (required for the entry in the plist stored on the server)
    NSLog(@"App BundleID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    if (launchOptions) {
        NSURL* launchURL = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
        if ([[launchURL scheme] isEqualToString:@"photoapplinktestapp-photoapplink"]) {
            // launched from another app
            
            // Let the app link manager parse the launch options
            // This is only necessary for the "return to previous app" functionality
            [applink parseAppLaunchOptions:launchOptions];
                        
            // basic app setup
            [window addSubview:navigationController.view];
            [window makeKeyAndVisible];
                        
            // get the image that was passed from previous app
            UIImage *image = [applink popPassedInImage];
            [rootViewController performSelector:@selector(setImage:) withObject:image afterDelay:0.0];
            
            // display bundle ID of calling app in Test App UI
            NSString* previousAppBundleID = [launchOptions objectForKey:@"UIApplicationLaunchOptionsSourceApplicationKey"];
            [rootViewController performSelector:@selector(setPreviousAppBundleID:) withObject:previousAppBundleID afterDelay:0.0];
            return YES;
        }
        else {
            // unknown URL scheme
            return NO;
        }
    }
    else {
        // normal launch from Springboard
        [self applicationDidFinishLaunching:application];
    }
    return YES;
}

// this function will be called when running under OS 2.x
// under OS 3.x we call it from didFinishLaunchingWithOptions: when launched without options
- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    // we did not receive an image, use default test image
    [rootViewController performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"TestImage.png"] afterDelay:0.0];
}


- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

