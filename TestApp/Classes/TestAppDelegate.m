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

#import "TestAppDelegate.h"
#import "TestAppRootViewController.h"
#import "PALManager.h"

@implementation TestAppDelegate

@synthesize rootViewController;
@synthesize window;
@synthesize navigationController;

// The following is the custom URL scheme that will be used by other apps to invoke this app
// Recommended format is "nameofyourapp-photoapplink"
// You have to define this URL scheme in your app's info.plist (see: http://bit.ly/YS49o)
// Your app and its URL scheme also need to be added to a plist stored on a server to be discoverable
// by other apps implementing the Photo App Link protocol.
static NSString* const APP_PHOTOAPPLINK_URL_SCHEME = @"photoapplinktestapp-photoapplink";



// Handle the URL that this app was invoked with via its custom URL scheme.
// This method is called by the different UIApplicationDelegate methods below.
// Returns YES if the app knows how to handle the URL, NO otherwise.
- (BOOL)handleURL:(NSURL *)url
{
    if ([[url scheme] isEqualToString:APP_PHOTOAPPLINK_URL_SCHEME]) {
        // Retrieve the image that was passed from previous app.
        PALManager* applink = [PALManager sharedPALManager];
        UIImage *image = [applink popPassedInImage];
        [self.rootViewController performSelector:@selector(setImage:) withObject:image afterDelay:0.0];
        return YES;
    }
    else {
        return NO;
    }
}

// Save your app state so the app can resume where the user left it on the next launch.
// We call this method before leaving the app. 
- (void)saveApplicationState
{
    // save your application state here ... 
}

#pragma mark -
#pragma UIApplicationDelegate methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // If you are not sure about your app's bundle ID, this prints it:
    // (required for the entry in the plist stored on the server)
    NSLog(@"App BundleID: %@", [[NSBundle mainBundle] bundleIdentifier]);
    
    // basic app setup
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    NSURL* launchURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (launchURL && [[[UIDevice currentDevice] systemVersion] floatValue] < 4.0f) {
        return [self handleURL:launchURL];
    }
    else {
        // normal launch from Springboard
        // use default test image
        [self.rootViewController performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"TestImage.png"] afterDelay:0.0];                                                                             
    }

    return YES;
}

// This method will be called on iOS 4.2 or later when the app is invoked via its custom URL scheme 
// If the app was not running already, application:didFinishLaunchingWithOptions: will be called first, 
// followed by this method
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [self handleURL:url];
}

// This method will be called for iOS versions before 4.2 when the app is invoked via its custom URL scheme 
// If the app was not running already, application:didFinishLaunchingWithOptions: will be called first, 
// followed by this method
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // The updateSupportedAppsInBackground method should be called right after app launch. 
    // It goes out to the server and downloads the latest list of supported applications and 
    // their custom URL schemes.
    PALManager* applink = [PALManager sharedPALManager];
    [applink updateSupportedAppsInBackground];    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // if we are running on an iOS4 device that isn't multitasking enabled
    // we do the state saving in applicationWillTerminate
    if (![[UIDevice currentDevice] isMultitaskingSupported]) return;
    
    [self saveApplicationState];
}

- (void) applicationWillTerminate:(UIApplication *)application 
{
    [self saveApplicationState];
}

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}


@end

