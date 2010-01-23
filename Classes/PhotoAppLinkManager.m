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

#import "PhotoAppLinkManager.h"

static NSString *const PLIST_DICT_USERPREF_KEY = @"PhotoAppLink_PListDictionary";
static NSString *const LASTUPDATE_USERPREF_KEY = @"PhotoAppLink_LastUpdateDate";
static NSString *const LAUNCH_DATE_KEY = @"launchDate";
static NSString *const SUPPORTED_APPS_PLIST_KEY = @"supportedApps";
static NSString *const PASTEBOARD_NAME = @"com.photoapplink.pasteboard";
#ifdef DEBUG 
const int MINIMUM_SECS_BETWEEN_UPDATES = 0; 
#else
// update list of supported apps every 3 days at most
const int MINIMUM_SECS_BETWEEN_UPDATES = 3 * 24 * 60 * 60; 
#endif

@interface PhotoAppLinkManager() 
@property (nonatomic, readonly) NSMutableDictionary* installedAppsURLSchemes;
@end

@implementation PhotoAppLinkManager

@dynamic destinationAppNames;
@dynamic installedAppsURLSchemes;

- (id)init
{
    self = [super init];
    if (self != nil) {
        NSString* osVersion = [[UIDevice currentDevice] systemVersion];
        // iPhone OS versions before 3.0 are missing required features.
        BOOL os_earlier_than_30 = [osVersion compare:@"3.0" options: NSNumericSearch] == NSOrderedAscending;
        if (os_earlier_than_30) {
            [self release];
            return nil;
        }
    }    
    
    return self;
}


// trigger background update of the list of supported apps
- (void)updateSupportedAppsInBackground
{
    [self performSelectorInBackground:@selector(requestSupportedAppURLSchemesUpdate) withObject:nil];    
}


// this method runs in a background thread and downloads the latest plist file with information
// on the supported apps and their URL schemes.
// This update is only performed once every few days
- (void)requestSupportedAppURLSchemesUpdate
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // check if we already updated recently
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDate* lastUpdateDate = [userPrefs objectForKey:LASTUPDATE_USERPREF_KEY];
    NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    if (secondsSinceLastUpdate < MINIMUM_SECS_BETWEEN_UPDATES) return;
    // Download dictionary from plist stored on server
#ifdef DEBUG 
    NSURL* plistURL = [NSURL URLWithString:@"http://www.photoapplink.com/photoapplink_debug.plist"];
#else
    NSURL* plistURL = [NSURL URLWithString:@"http://www.photoapplink.com/photoapplink.plist"];
#endif
    NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    //NSLog(@"Received updated plist dict: %@", plistDict);
    if (plistDict) {
        [self performSelectorOnMainThread:@selector(storeUpdatedPlistContent:) 
                               withObject:plistDict waitUntilDone:YES];        
    }
    [pool drain];
}

- (void)storeUpdatedPlistContent:(NSDictionary*)plistDict
{
    // store the new dictionary in the user preferences
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    [userPrefs setObject:plistDict forKey:PLIST_DICT_USERPREF_KEY];
    // store time stamp of update
    [userPrefs setObject:[NSDate date] forKey:LASTUPDATE_USERPREF_KEY];
    [userPrefs synchronize];
    // invalidate list of installed supported apps
    [installedAppsURLSchemes release];
    installedAppsURLSchemes = nil;
}


- (NSDictionary*)installedAppsURLSchemes
{
    if (installedAppsURLSchemes) return installedAppsURLSchemes;
    installedAppsURLSchemes = [[NSMutableDictionary alloc] init];
    // get dictionary of all supported apps from the user defaults
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary* plistDict = [userPrefs dictionaryForKey:PLIST_DICT_USERPREF_KEY];
    // deactivate until official launch date
    NSDate* launchDate = [plistDict objectForKey:LAUNCH_DATE_KEY];
    if (launchDate && ([launchDate compare:[NSDate date]] == NSOrderedDescending)) return nil;
    NSArray* supportedApps = [plistDict objectForKey:SUPPORTED_APPS_PLIST_KEY];
    if (supportedApps == nil) return nil;
    NSString* ownBundleID = [[NSBundle mainBundle] bundleIdentifier];
    for (NSDictionary* appInfo in supportedApps) {
        NSString* appName = [appInfo objectForKey:@"name"];
        NSString* urlString = [[appInfo objectForKey:@"scheme"] stringByAppendingString:@"://"];
        NSURL *launchURL= [NSURL URLWithString:urlString];
        NSString* bundleID = [appInfo objectForKey:@"bundleID"];
        // check which of the supported apps are actually supported on the device
        if ( ![bundleID isEqualToString:ownBundleID] && [[UIApplication sharedApplication] canOpenURL:launchURL]) {
            [installedAppsURLSchemes setValue:[appInfo objectForKey:@"scheme"] forKey:appName];
        }
    }
    return installedAppsURLSchemes;
}

- (NSArray*)destinationAppNames
{
    return [self.installedAppsURLSchemes allKeys];
}

- (void)invokeApplication:(NSString*)appName withImage:(UIImage*)image
{
    // the class alias is required to allow the code to compile and load under iPhone OS 2.x
    Class PasteBoardClass = NSClassFromString(@"UIPasteboard");
    id pasteboard = [PasteBoardClass pasteboardWithName:PASTEBOARD_NAME create:YES];
    [pasteboard setPersistent:YES];
    NSData* jpegData = UIImageJPEGRepresentation(image, 0.99);
    [pasteboard setData:jpegData forPasteboardType:@"public.jpeg"];
    
    // get URL for the destination app name
    NSString* urlString = [[self.installedAppsURLSchemes objectForKey:appName] stringByAppendingString:@"://edit"];
    NSURL* appLaunchURL = [NSURL URLWithString:urlString];
    // launch the app
    [[UIApplication sharedApplication] openURL:appLaunchURL];
}

- (UIImage*)popPassedInImage
{
    Class PasteBoardClass = NSClassFromString(@"UIPasteboard");
    // Note: We are just looking for an existing pasteboard, however specifying create:NO 
    // will never find the existing pasteboard. This is a bug in Apple's implementation 
    id pasteboard = [PasteBoardClass pasteboardWithName:PASTEBOARD_NAME create:YES];
    UIImage* image = [pasteboard image];
    // clear the pasteboard
    [pasteboard setItems:nil];
    return image;
}


#pragma mark -
#pragma mark Singleton 

static PhotoAppLinkManager *s_sharedPhotoAppLinkManager = nil;

+ (PhotoAppLinkManager*)sharedPhotoAppLinkManager
{
    if (s_sharedPhotoAppLinkManager == nil) {
        s_sharedPhotoAppLinkManager = [[super allocWithZone:NULL] init];
    }
    return s_sharedPhotoAppLinkManager;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPhotoAppLinkManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}



@end

