//
//  PhotoToolchainManager.m
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright 2009 Pocket Pixels Inc. All rights reserved.
//

#import "PhotoToolchainManager.h"

static NSString *const PLIST_DICT_USERPREF_KEY = @"PhotoToolchain_PListDictionary";
static NSString *const LASTUPDATE_USERPREF_KEY = @"PhotoToolchain_LastUpdateDate";
static NSString *const SUPPORTED_APPS_PLIST_KEY = @"supportedApps";
static NSString *const PASTEBOARD_NAME = @"com.phototoolchain.pasteboard";
// update list of supported apps every 3 days at most
//const int MINIMUM_SECS_BETWEEN_UPDATES = 3 * 24 * 60 * 60; 
const int MINIMUM_SECS_BETWEEN_UPDATES = 0; 

@interface PhotoToolchainManager() 
@property (nonatomic, retain) NSMutableDictionary* installedAppsURLSchemes;
@end

@implementation PhotoToolchainManager

@dynamic destinationAppNames;
@dynamic installedAppsURLSchemes;

- (id) init
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
    // TODO register memory notification handler
    
    // trigger background update of the list of supported apps
    [self performSelectorInBackground:@selector(requestSupportedAppURLSchemesUpdate) withObject:nil];
    
    return self;
}


// this method runs in a background thread and downloads the latest plist file with information
// on the supported apps and their URL schemes.
// This update is only performed once every few days
-(void) requestSupportedAppURLSchemesUpdate
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // check if we already updated recently
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDate* lastUpdateDate = [userPrefs objectForKey:LASTUPDATE_USERPREF_KEY];
    NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    if (secondsSinceLastUpdate < MINIMUM_SECS_BETWEEN_UPDATES) return;
    NSLog(@"Downloading updated plist");
    // Download dictionary from plist stored on server
#ifdef DEBUG 
    NSURL* plistURL = [NSURL URLWithString:@"http://www.pocketpixels.com/phototoolchainapps_debug.plist"];
#else
    NSURL* plistURL = [NSURL URLWithString:@"http://www.pocketpixels.com/phototoolchainapps.plist"];
#endif
    NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    if (plistDict) {
        [self performSelectorOnMainThread:@selector(storeUpdatedPlistContent:) 
                               withObject:plistDict waitUntilDone:YES];        
    }
    [pool drain];
}

-(void) storeUpdatedPlistContent:(NSDictionary*) plistDict
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


-(NSDictionary*) installedAppsURLSchemes
{
    if (installedAppsURLSchemes) return installedAppsURLSchemes;
    installedAppsURLSchemes = [[NSMutableDictionary alloc] init];
    // get dictionary of all supported apps from the user defaults
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary* plistDict = [userPrefs dictionaryForKey:PLIST_DICT_USERPREF_KEY];
    NSArray* supportedApps = [plistDict objectForKey:SUPPORTED_APPS_PLIST_KEY];
    if (supportedApps == nil) return nil;
    NSString* ownBundleID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    for (NSDictionary* appInfo in supportedApps) {
        NSString* appName = [appInfo objectForKey:@"name"];
        NSURL *launchURL= [NSURL URLWithString:[appInfo objectForKey:@"url"]];
        NSString* bundleID = [appInfo objectForKey:@"bundleID"];
        // check which of the supported apps are actually supported on the device
        if ( ![bundleID isEqualToString:ownBundleID] && [[UIApplication sharedApplication] canOpenURL:launchURL]) {
            [installedAppsURLSchemes setValue:launchURL forKey:appName];
        }
    }
    return installedAppsURLSchemes;
}

-(NSArray*) destinationAppNames
{
    return [self.installedAppsURLSchemes allKeys];
}

-(void) invokeApplication:(NSString*) appName withImage:(UIImage*) image
{
    // this is to allow the code to compile and load under iPhone OS 2.x
    Class PasteBoardClass = NSClassFromString(@"UIPasteboard");
    id pasteboard = [PasteBoardClass pasteboardWithName:PASTEBOARD_NAME create:YES];
    [pasteboard setPersistent:YES];
    [pasteboard setImage:image];
    // get URL for the destination app name
    NSURL* appLaunchURL = [self.installedAppsURLSchemes objectForKey:appName];
    // launch the app
    [[UIApplication sharedApplication] openURL:appLaunchURL];
}

-(UIImage*) popPassedInImage
{
    Class PasteBoardClass = NSClassFromString(@"UIPasteboard");
    id pasteboard = [PasteBoardClass pasteboardWithName:PASTEBOARD_NAME create:NO];
    if (pasteboard == nil) return nil;
    UIImage* image = [pasteboard image];
    // clear the pasteboard
    [pasteboard setItems:nil];
    return image;
}

#pragma mark -
#pragma mark Singleton 

static PhotoToolchainManager *s_sharedPhotoToolchainManager = nil;

+ (PhotoToolchainManager*)sharedPhotoToolchainManager
{
    if (s_sharedPhotoToolchainManager == nil) {
        s_sharedPhotoToolchainManager = [[super allocWithZone:NULL] init];
    }
    return s_sharedPhotoToolchainManager;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPhotoToolchainManager] retain];
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
