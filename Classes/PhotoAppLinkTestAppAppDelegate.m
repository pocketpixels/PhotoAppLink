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

// The following is the custom URL scheme that will be used by other apps to invoke this app
// Recommended format is "nameofyourapp-photoapplink"
// You have to define this URL scheme in your app's info.plist (see: http://bit.ly/YS49o)
// Your app and its URL scheme also need to be added to a plist stored on a server to be discoverable
// by other apps implementing the Photo App Link protocol.
static NSString* const APP_PHOTOAPPLINK_URL_SCHEME = @"photoapplinktestapp-photoapplink";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // NOTE: If your app already uses the handleOpenURL: scheme, it is probably best to stick with that.
    //       Implementing didFinishLaunchingWithOptions: when running under 3.0 causes this method to 
    //       always be called rather than the applicationDidFinishLaunching: & handleOpenURL: combination.
    //       Under 2.x didFinishLaunchingWithOptions: will be ignored, so a different code path will be taken at launch.
    //       If your code does not currently implement handleOpenURL: I would recommend the scheme used in this example: 
    //          use didFinishLaunchingWithOptions: to handle URL & notification launches, forward normal launches 
    //          to applicationDidFinishLaunching: (which will also be called directly when running under 2.x)
    
    // The updateSupportedAppsInBackground method should be called right after app launch. 
    // It goes out to the server and downloads the latest list of supported applications and 
    // their custom URL schemes.
    // If you are using applicationDidFinishLaunching: & handleOpenURL: make sure you stick this into 
    // applicationDidFinishLaunching: in order to trigger the implicit background update.
    PhotoAppLinkManager* applink = [PhotoAppLinkManager sharedPhotoAppLinkManager];
    [applink updateSupportedAppsInBackground];

    // If you are not sure about your app's bundle ID, this prints it:
    // (required for the entry in the plist stored on the server)
    NSLog(@"App BundleID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    if (launchOptions) {
        NSURL* launchURL = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
        if ([[launchURL scheme] isEqualToString:APP_PHOTOAPPLINK_URL_SCHEME]) {
            // launched from another app via our Photo App Link URL scheme
            
            // basic app setup
            [window addSubview:navigationController.view];
            [window makeKeyAndVisible];
                        
            // Retrieve the image that was passed from previous app.
            // You could (and maybe should) instead access this image during a later stage of the launch process 
            // rather than doing it directly in this launch handler
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

