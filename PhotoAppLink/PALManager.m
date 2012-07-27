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
#import "PALConfig.h"

static NSString *const PLIST_DICT_USERPREF_KEY = @"PhotoAppLink_PListDictionary";
static NSString *const PLIST_MDATE_USERPREF_KEY = @"PhotoAppLink_PlistLastModifiedDate";
static NSString *const PLIST_ETAG_USERPREF_KEY = @"PhotoAppLink_PlistLastETag";
static NSString *const LASTUPDATE_USERPREF_KEY = @"PhotoAppLink_LastUpdateDate";
static NSString *const LAUNCH_DATE_KEY = @"launchDate";
static NSString *const SUPPORTED_APPS_PLIST_KEY = @"supportedApps";
static NSString *const PASTEBOARD_NAME = @"com.photoapplink.pasteboard";
static NSString *const RECEIVED_DATA_KEY = @"ReceivedDataKey";
static NSString *const COMPLETION_BLOCK_KEY = @"CompletionBlockKey";
static NSString *const APPINFO_KEY = @"AppInfoKey";


#ifdef DEBUG 
const int MINIMUM_SECS_BETWEEN_UPDATES = 0; 
#else
// update list of supported apps every 4 hours at most (to avoid unneccessary network access)
const int MINIMUM_SECS_BETWEEN_UPDATES = 4 * 60 * 60; 
#endif

@interface PALManager()
{
    CFMutableDictionaryRef connectionToData;
    NSMutableDictionary*   loadedIcons;
}
@property (nonatomic,copy) NSArray *supportedApps;
@property (nonatomic,retain) UIImage *imageToSend;
@end

@implementation PALManager

@synthesize supportedApps;
@synthesize imageToSend;

// Since the PALManager class is a singleton, the init method will only ever be called once
- (id)init
{
    self = [super init];
    if (self) {
        loadedIcons = [NSMutableDictionary new];
        
        // This will map NSURLConnections to downloaded data using the connection as the key.  We can't use NSMutableDictionary
        // because NSURLConnection does not support copy.
        connectionToData = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedMemoryWarning)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

// trigger background update of the list of supported apps
// This update is only performed once every few days
- (void)updateSupportedAppsInBackground
{
    // invalidate cached list of supported apps
    self.supportedApps = nil;

    // check if we already updated recently
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    NSDate* lastUpdateDate = [userPrefs objectForKey:LASTUPDATE_USERPREF_KEY];
    NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:lastUpdateDate];
    if (!lastUpdateDate || secondsSinceLastUpdate > MINIMUM_SECS_BETWEEN_UPDATES) {
        [self performSelectorInBackground:@selector(requestSupportedAppURLSchemesUpdate) withObject:nil];            
    }
}


// this method runs in a background thread and downloads the latest plist file with information
// on the supported apps and their URL schemes.
- (void)requestSupportedAppURLSchemesUpdate
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSUserDefaults* userPrefs = [NSUserDefaults standardUserDefaults];
    @try {
        // Download dictionary from plist stored on server
#ifdef DEBUG 
        NSURL* plistURL = [NSURL URLWithString:DEBUG_PLIST_URL];
#else
        NSURL* plistURL = [NSURL URLWithString:@"http://www.photoapplink.com/photoapplink.plist"];
#endif
        
        // performing a conditional HTTP GET in order to only download the server side plist data
        // if it has been modified. 
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:plistURL 
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:30.0];
        NSString* previousLastModifiedDate = [userPrefs objectForKey:PLIST_MDATE_USERPREF_KEY];
        if (previousLastModifiedDate != nil) {
            [request setValue:previousLastModifiedDate forHTTPHeaderField:@"If-Modified-Since"];
        }
        NSString* previousEtag = [userPrefs objectForKey:PLIST_ETAG_USERPREF_KEY];
        if (previousEtag != nil) {
            [request setValue:previousEtag forHTTPHeaderField:@"If-None-Match"];
        }
        NSHTTPURLResponse* response = nil;
        // This method is executed on a background thread, so doing a synchronous request is fine and simplifies things.
        NSData* receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
        if ([response statusCode] == 200) {
            // We received an updated plist file
            // Store the "Last-Modified" date to use for the next conditional HTTP GET
            NSString* lastModifiedDate = [[response allHeaderFields] objectForKey:@"Last-Modified"];
            NSString* eTag = [[response allHeaderFields] objectForKey:@"ETag"]; 
            if (eTag == nil) eTag = [[response allHeaderFields] objectForKey:@"Etag"];
            [userPrefs setObject:lastModifiedDate forKey:PLIST_MDATE_USERPREF_KEY];
            [userPrefs setObject:eTag forKey:PLIST_ETAG_USERPREF_KEY];
            
            // decode the received plist data
            CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault, (CFDataRef)receivedData,
                                                                       kCFPropertyListImmutable, NULL);
            if ([(id)plist isKindOfClass:[NSDictionary class]]) {
                NSDictionary* plistDict = (NSDictionary*) plist;
                // store the new dictionary in the user preferences
                [userPrefs setObject:plistDict forKey:PLIST_DICT_USERPREF_KEY];
                // store time stamp of update
                [userPrefs setObject:[NSDate date] forKey:LASTUPDATE_USERPREF_KEY];
                // invalidate cached list of supported apps
                self.supportedApps = nil;
            }
            [userPrefs synchronize];
            if (plist) CFRelease(plist);
        }
    }
    @catch (NSException * e) {
        NSLog(@"Caught exception in -[PALManager requestSupportedAppURLSchemesUpdate]: %@", e);
    }
    [pool release];
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
    self.supportedApps = newSupportedApps;
    return supportedApps;
}

- (NSArray*)destinationApps
{
    return [self.supportedApps filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"installed=TRUE"]];
}

- (NSArray*)moreApps
{
    NSString* deviceType = [[UIDevice currentDevice] model];
    BOOL isIPad = [deviceType hasPrefix:@"iPad"];
    NSPredicate* appsToShowPredicate;
    // Only show apps that are not yet installed (as far as we can tell) and that are supported on the user's device
    if (isIPad) {
        appsToShowPredicate = [NSPredicate predicateWithFormat:
                               @"installed=FALSE AND liveOnAppStore=TRUE AND NOT platform BEGINSWITH[cd] 'iPhone'"];
    }
    else {
        appsToShowPredicate = [NSPredicate predicateWithFormat:
                               @"installed=FALSE AND liveOnAppStore=TRUE AND NOT platform BEGINSWITH[cd] 'iPad'"];            
    }
    
    return [self.supportedApps filteredArrayUsingPredicate:appsToShowPredicate];
}

- (void)invokeApplication:(PALAppInfo*) appInfo withImage:(UIImage*)image;
{
    UIPasteboard* pasteboard = [UIPasteboard pasteboardWithName:PASTEBOARD_NAME create:YES];
    [pasteboard setPersistent:YES];
    
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
	BOOL hasAlpha = (alpha == kCGImageAlphaFirst ||
                     alpha == kCGImageAlphaLast ||
                     alpha == kCGImageAlphaPremultipliedFirst ||
                     alpha == kCGImageAlphaPremultipliedLast);
	if (hasAlpha) {
		[pasteboard setData:UIImagePNGRepresentation(image) forPasteboardType:@"public.png"];
	} else {
		[pasteboard setData:UIImageJPEGRepresentation(image, 0.99) forPasteboardType:@"public.jpeg"];
	}


    [[UIApplication sharedApplication] openURL:appInfo.scheme];
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
    NSString* lastPathComponent = [[[app.thumbnailURL path] componentsSeparatedByString:@"/"] lastObject];
    NSString* fileName = [NSString stringWithFormat:@"%@_%@", app.bundleID, lastPathComponent];
    NSString* fullPath = [[self appIconCacheDirectory] stringByAppendingPathComponent:fileName];
    return fullPath;
}

- (UIImage*)cachedIconForApp:(PALAppInfo*)app
{
    UIImage* icon = [loadedIcons objectForKey:app.thumbnailURL];
    
    if (icon == nil) {
        icon = [UIImage imageWithContentsOfFile:[self cachedIconPathForApp:app]];
        
        // if we pulled an icons from the cache, keep it in memory
        if (icon != nil) {
            [loadedIcons setObject:icon forKey:app.thumbnailURL];
        }
    }
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


- (void)asyncIconForApp:(PALAppInfo *)appInfo
         withCompletion:(PALImageRequestHandler)completion
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:appInfo.thumbnailURL
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                              timeoutInterval:60.0];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [connection start];
   
    CFDictionaryAddValue(connectionToData, connection, [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableData data], RECEIVED_DATA_KEY,
                                                        [completion copy], COMPLETION_BLOCK_KEY,
                                                        appInfo, APPINFO_KEY, nil]);
}


- (void)receivedMemoryWarning
{
    if (loadedIcons != nil) [loadedIcons removeAllObjects];
}



#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableDictionary* connectionInfo = CFDictionaryGetValue(connectionToData, connection);
    [[connectionInfo objectForKey:RECEIVED_DATA_KEY] appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSMutableDictionary* connectionInfo = CFDictionaryGetValue(connectionToData, connection);
    PALImageRequestHandler completion = [connectionInfo objectForKey:COMPLETION_BLOCK_KEY];
    NSData* imageData = [connectionInfo objectForKey:RECEIVED_DATA_KEY];
    PALAppInfo* appInfo = [connectionInfo objectForKey:APPINFO_KEY];
    
    UIImage* image = [[UIImage alloc] initWithData:imageData];
    
    if (image == nil) {
        image = [UIImage imageNamed:GENERIC_APP_ICON];
    }
    else {
        NSString* cachedIconPath = [self cachedIconPathForApp:appInfo];
        [imageData writeToFile:cachedIconPath atomically:YES];
        
        if (loadedIcons != nil) {
            [loadedIcons setObject:image forKey:appInfo.thumbnailURL];
        }
    }

    completion(image, nil);
    
    CFDictionaryRemoveValue(connectionToData, connection);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSMutableDictionary* connectionInfo;
    connectionInfo = CFDictionaryGetValue(connectionToData, connection);
    PALImageRequestHandler completion = [connectionInfo objectForKey:COMPLETION_BLOCK_KEY];
    
    completion(nil, error);
    
    CFDictionaryRemoveValue(connectionToData, connection);
}

#pragma mark -
#pragma mark Action Sheet

- (UIActionSheet*)actionSheetToSendImage:(UIImage*)image
{
    NSArray *apps = self.destinationApps;
    if ([apps count] > 0)
    {
        self.imageToSend = image;
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.title = @"Send To";
        actionSheet.delegate = self;
        
        for (PALAppInfo *info in apps) {
            [actionSheet addButtonWithTitle:info.name];
        }
        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        
        return [actionSheet autorelease];
    }
    
    return nil;
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

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

@end
