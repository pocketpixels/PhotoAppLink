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

#import "PALManager.h"
#import "PALAppInfo.h"


// If you are not using app icons to display the list of supported
// apps in your UI, you can set this to NO to disable downloading 
// of these app icons
static BOOL USING_APP_ICONS = YES;

// Substitute this for testing with your own edited server side plist URL
// (Make sure to set up your XCode project so that DEBUG is defined in debug builds, 
//  otherwise the production plist file will be used)
static NSString *const DEBUG_PLIST_URL = @"http://dl.dropbox.com/u/261469/photoapplink_debug.plist";

static NSString *const PLIST_DICT_USERPREF_KEY = @"PhotoAppLink_PListDictionary";
static NSString *const LASTUPDATE_USERPREF_KEY = @"PhotoAppLink_LastUpdateDate";
static NSString *const LAUNCH_DATE_KEY = @"launchDate";
static NSString *const SUPPORTED_APPS_PLIST_KEY = @"supportedApps";
static NSString *const PASTEBOARD_NAME = @"com.photoapplink.pasteboard";

#ifdef DEBUG 
const int MINIMUM_SECS_BETWEEN_UPDATES = 0; 
#else
// update list of supported apps every 3 days at most (to avoid unneccessary network access)
const int MINIMUM_SECS_BETWEEN_UPDATES = 3 * 24 * 60 * 60; 
#endif

@interface PALManager() 
@property (nonatomic,  copy) NSArray *supportedApps;
@property (nonatomic,retain) UIImage *imageToSend;
- (void)downloadAndCacheIconsForAllApps;
@end

@implementation PALManager

@synthesize supportedApps;
@synthesize imageToSend;


// trigger background update of the list of supported apps
// This update is only performed once every few days
- (void)updateSupportedAppsInBackground
{
    // check if we already updated recently
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDate* lastUpdateDate = [userPrefs objectForKey:LASTUPDATE_USERPREF_KEY];
    NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    if (!lastUpdateDate || secondsSinceLastUpdate > MINIMUM_SECS_BETWEEN_UPDATES) {
        [self performSelectorInBackground:@selector(requestSupportedAppURLSchemesUpdate) withObject:nil];            
    }
    else if (USING_APP_ICONS){
        // still check for any missing app icons and download them
        [self performSelectorInBackground:@selector(downloadAndCacheIconsForAllApps) withObject:nil];            
    }
}


// this method runs in a background thread and downloads the latest plist file with information
// on the supported apps and their URL schemes.
- (void)requestSupportedAppURLSchemesUpdate
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // Download dictionary from plist stored on server
#ifdef DEBUG 
    NSURL* plistURL = [NSURL URLWithString:DEBUG_PLIST_URL];
#else
    NSURL* plistURL = [NSURL URLWithString:@"http://www.photoapplink.com/photoapplink.plist"];
#endif
    NSDictionary* plistDict = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    //NSLog(@"Received updated plist dict: %@", plistDict);
    if (plistDict) {
        [self performSelectorOnMainThread:@selector(storeUpdatedPlistContent:) 
                               withObject:plistDict waitUntilDone:YES];        
    }
    [pool release];
}

- (void)storeUpdatedPlistContent:(NSDictionary*)plistDict
{
    // store the new dictionary in the user preferences
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    [userPrefs setObject:plistDict forKey:PLIST_DICT_USERPREF_KEY];
    // store time stamp of update
    [userPrefs setObject:[NSDate date] forKey:LASTUPDATE_USERPREF_KEY];
    [userPrefs synchronize];
    
    // invalidate list of supported apps
    self.supportedApps = nil;
    if (USING_APP_ICONS) {
        // download app icons for all apps in the new list
        [self performSelectorInBackground:@selector(downloadAndCacheIconsForAllApps) withObject:nil];        
    }
}

- (NSArray*)supportedApps
{
    if (supportedApps) return supportedApps;
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary* plistDict = [userPrefs dictionaryForKey:PLIST_DICT_USERPREF_KEY];
    
    // deactivate until official launch date
    NSDate* launchDate = [plistDict objectForKey:LAUNCH_DATE_KEY];
    if (launchDate && ([launchDate compare:[NSDate date]] == NSOrderedDescending)) return nil;
    
    NSArray* plistApps = [plistDict objectForKey:SUPPORTED_APPS_PLIST_KEY];
    if (plistApps == nil) return nil;
    
    NSString* ownBundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSMutableArray* newSupportedApps = [NSMutableArray array];
    for (NSDictionary* plistAppInfo in plistApps) {
        PALAppInfo* appInfo = [[PALAppInfo alloc] initWithPropertyDict:plistAppInfo];
        // Drop entry for the currently running app
        if (![appInfo.bundleID isEqualToString:ownBundleID]) {
            [newSupportedApps addObject:appInfo];
        }
        [appInfo release];
    }
    supportedApps = [newSupportedApps copy];
    return supportedApps;
}

- (NSArray*)destinationApps
{
    return [self.supportedApps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K=TRUE", @"installed"]];
}

- (void)invokeApplication:(PALAppInfo*) appInfo withImage:(UIImage*)image;
{
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:PASTEBOARD_NAME create:YES];
    [pasteboard setPersistent:YES];
    NSData* jpegData = UIImageJPEGRepresentation(image, 0.99);
    [pasteboard setData:jpegData forPasteboardType:@"public.jpeg"];
    [[UIApplication sharedApplication] openURL:appInfo.urlScheme];
}

- (UIImage*)popPassedInImage
{
    // Note: We are just looking for an existing pasteboard, however specifying create:NO 
    // will never find the existing pasteboard. This is a bug in Apple's implementation 
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:PASTEBOARD_NAME create:YES];
    UIImage* image = [pasteboard image];
    // clear the pasteboard
    [pasteboard setItems:nil];
    return image;
}

#pragma mark -
#pragma mark App icon cache

- (NSString*)appIconCacheDirectory
{
    NSArray  *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *generalcacheDirectory = [cachePaths objectAtIndex:0];
    NSString *iconDirectory = [generalcacheDirectory stringByAppendingPathComponent:@"PhotoAppLink_AppIcons"];
    return iconDirectory;
}

- (void)createAppIconCacheDirectory
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self appIconCacheDirectory]]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[self appIconCacheDirectory] 
                                  withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)clearAppIconCache
{
    [[NSFileManager defaultManager] removeItemAtPath:[self appIconCacheDirectory] error:nil];
    [self createAppIconCacheDirectory];
}

- (NSString*)cachedIconPathForApp:(PALAppInfo*)app
{
    NSString* fileName = [NSString stringWithFormat:@"%@_%@", app.bundleID, [app.thumbnailURL lastPathComponent]];
    NSString* fullPath = [[self appIconCacheDirectory] stringByAppendingPathComponent:fileName];
    return fullPath;
}

- (UIImage*)cachedIconForApp:(PALAppInfo*)app
{
    UIImage* icon = [UIImage imageWithContentsOfFile:[self cachedIconPathForApp:app]];
    if (icon == nil) return nil;
    BOOL isRetina = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f;
    if (!isRetina || [icon scale] > 1.0) return icon;
    else {
        // need to create image with appropriate scale
        float scale = [[UIScreen mainScreen] scale];
        UIImageOrientation orientation = [icon imageOrientation];
        UIImage* retinaIcon = [UIImage imageWithCGImage:icon.CGImage scale:scale orientation:orientation];
        return retinaIcon;
    }
}

- (void)downloadAndCacheIconsForAllApps
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    // ensure that the cache directory exists
    [self createAppIconCacheDirectory];
    
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDictionary* plistDict = [userPrefs dictionaryForKey:PLIST_DICT_USERPREF_KEY];    
    NSArray* plistApps = [plistDict objectForKey:SUPPORTED_APPS_PLIST_KEY];
    if (plistApps == nil) return;
    
    for (NSDictionary* plistAppInfo in plistApps) {
        PALAppInfo* appInfo = [[PALAppInfo alloc] initWithPropertyDict:plistAppInfo];
        NSString* cachedIconPath = [self cachedIconPathForApp:appInfo];
        if (![[NSFileManager defaultManager] isReadableFileAtPath:cachedIconPath]) {
            NSData* imageData = [NSData dataWithContentsOfURL:appInfo.thumbnailURL];
            // verify that the data is actually an image
            UIImage* image = [UIImage imageWithData:imageData];
            if (image != nil) {
                [imageData writeToFile:cachedIconPath atomically:YES];                
            }
        }
    }
    [pool release];
}


#pragma mark -
#pragma mark Action Sheet

- (UIActionSheet*)actionSheetToSendImage:(UIImage*)image
{
    self.imageToSend = image;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"Send To";
    actionSheet.delegate = self;
    
    NSArray *apps = self.destinationApps;
    for (PALAppInfo *info in apps) {
        [actionSheet addButtonWithTitle:info.appName];
    }
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    return [actionSheet autorelease];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSArray *apps = self.destinationApps;
    if (buttonIndex < [apps count]) {
        PALAppInfo *app = [apps objectAtIndex:buttonIndex];
        [self invokeApplication:app withImage:self.imageToSend];
    }
    self.imageToSend = nil;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet {
    self.imageToSend = nil;
}


#pragma mark -
#pragma mark Singleton 

static PALManager *s_sharedPhotoAppLinkManager = nil;

+ (PALManager*)sharedPALManager
{
    if (s_sharedPhotoAppLinkManager == nil) {
        s_sharedPhotoAppLinkManager = [[super allocWithZone:NULL] init];
    }
    return s_sharedPhotoAppLinkManager;    
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedPALManager] retain];
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
