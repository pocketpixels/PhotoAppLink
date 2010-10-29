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
    // If you are not sure about your app's bundle ID, this prints it:
    // (required for the entry in the plist stored on the server)
    NSLog(@"App BundleID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    // basic app setup
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    if (launchOptions) {
        NSURL* launchURL = [launchOptions objectForKey:@"UIApplicationLaunchOptionsURLKey"];
        if ([[launchURL scheme] isEqualToString:APP_PHOTOAPPLINK_URL_SCHEME]) {
            // launched from another app via our Photo App Link URL scheme
            
            // In versions prior to 4.0 handleOpenURL is not called 
            // if didFinishLaunchingWithOptions: is implemented.
            // In later versions it DOES get called
            // So we have to manually call it here for pre-4.0 iOS versions
            NSString* osVersion = [[UIDevice currentDevice] systemVersion];
            if ([osVersion floatValue] < 4.0) {
                [self application:application handleOpenURL:launchURL];
            }            
            return YES;
        }
        else {
            // unknown URL scheme
            return NO;
        }
    }
    else {
        // normal launch from Springboard
        // use default test image
        [self.rootViewController performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"TestImage.png"] afterDelay:0.0];                                                                             
    }
    return YES;
}


- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{    
    if ([[url scheme] isEqualToString:APP_PHOTOAPPLINK_URL_SCHEME]) {
        // Retrieve the image that was passed from previous app.
        // You could (and likely should) instead access this image during a later stage of the launch process 
        // rather than doing it directly in this launch handler
        PhotoAppLinkManager* applink = [PhotoAppLinkManager sharedPhotoAppLinkManager];
        UIImage *image = [applink popPassedInImage];
        [self.rootViewController performSelector:@selector(setImage:) withObject:image afterDelay:0.0];
        return YES;
    }
    else {
        return NO;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // The updateSupportedAppsInBackground method should be called right after app launch. 
    // It goes out to the server and downloads the latest list of supported applications and 
    // their custom URL schemes.
    PhotoAppLinkManager* applink = [PhotoAppLinkManager sharedPhotoAppLinkManager];
    [applink updateSupportedAppsInBackground];    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // if we are running on an iOS4 device that isn't multitasking enabled
    // we do the state saving in applicationWillTerminate
    if (![[UIDevice currentDevice] isMultitaskingSupported]) return;

    // dismiss any modal views and such that you don't want to be on screen when 
    // the user returns to the app (maybe much later)
    [navigationController popToRootViewControllerAnimated:NO];
    
    // save your app state here
}

- (void) applicationWillTerminate:(UIApplication *)application 
{
    // save your app state here
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

