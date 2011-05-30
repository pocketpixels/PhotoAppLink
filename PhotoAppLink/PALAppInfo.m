//
//  PALAppInfo.m
//

#import "PALAppInfo.h"
#import "PALManager.h"


// Substitute your own Linkshare Site ID here if you like.
// This Linkshare ID is used to create affiliate links to 
// supported apps on the App Store
static NSString *const LINKSHARE_SITE_ID = @"2695383";
static NSString *const GENERIC_APP_ICON = @"PAL_unknown_app_icon.png";

@implementation PALAppInfo

@synthesize appName, urlScheme, appDescription, bundleID, appleID;
@synthesize platform, freeApp;
@synthesize thumbnailURL, installed, canSend, canReceive;
@synthesize thumbnail;

- (id)initWithPropertyDict:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        bundleID = [[properties objectForKey:@"bundleID"] copy];
        appName = [[properties objectForKey:@"name"] copy];
        canSend = [[properties objectForKey:@"sends"] boolValue];
        canReceive = [[properties objectForKey:@"receives"] boolValue];
        urlScheme = [[NSURL alloc] initWithString:[[properties objectForKey:@"scheme"] 
                                                   stringByAppendingString:@"://"]];
        appleID = [[properties objectForKey:@"appleID"] copy];
        platform = [[properties objectForKey:@"platform"] copy];
        if (platform == nil) platform = [[NSString alloc] initWithString:@"universal"];
        freeApp = [[properties objectForKey:@"free"] boolValue];
        installed = (canReceive && [[UIApplication sharedApplication] canOpenURL:urlScheme]);
        appDescription = [[properties objectForKey:@"description"] copy];
        // select appropriate app icon for this device
        BOOL isRetina = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f;
        NSString* thumbnailKey = isRetina ? @"thumbnail2x" : @"thumbnail";
        thumbnailURL = [[NSURL alloc] initWithString:[properties objectForKey:thumbnailKey]];            
    }
    return self;
}

- (void) dealloc
{
    [appName release];
	[urlScheme release];
	[bundleID release];
    [appleID release];
	[thumbnailURL release];
    [thumbnail release];
    [platform release];
    [super dealloc];
}

- (NSURL*)appStoreLink
{
    if (self.appleID == nil) return nil;
    // This creates a LinkShare affiliate link, but without any redirection. It does straight to the app store item.
    NSString* affiliateLink = [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@?mt=8&partnerId=30&tduid=%@",
                               self.appleID, LINKSHARE_SITE_ID];
    return [NSURL URLWithString:affiliateLink];
}

- (UIImage*)thumbnail
{
    if (thumbnail) return thumbnail;
    thumbnail = [[[PALManager sharedPALManager] cachedIconForApp:self] retain];
    if (thumbnail) return thumbnail;
    else return [UIImage imageNamed:GENERIC_APP_ICON];
}

@end



