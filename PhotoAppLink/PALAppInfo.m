//
//  PALAppInfo.m
//

#import "PALAppInfo.h"
#import "PALManager.h"
#import "PALConfig.h"

@implementation PALAppInfo

@synthesize name, scheme, appDescription, bundleID, appleID;
@synthesize platform, freeApp;
@synthesize thumbnailURL, installed, canSend, canReceive;
@synthesize thumbnail;

- (id)initWithPropertyDict:(NSDictionary*)properties {
    self = [super init];
    if (self) {
        bundleID = [[properties objectForKey:@"bundleID"] copy];
        name = [[properties objectForKey:@"name"] copy];
        canSend = [[properties objectForKey:@"canSend"] boolValue];
        canReceive = [[properties objectForKey:@"canReceive"] boolValue];
        NSString* schemeStr = [[properties objectForKey:@"scheme"] stringByAppendingString:@"://"];
        if (schemeStr != nil) scheme = [[NSURL alloc] initWithString:schemeStr];
        appleID = [[properties objectForKey:@"appleID"] copy];
        platform = [[properties objectForKey:@"platform"] copy];
        if (platform == nil) platform = [[NSString alloc] initWithString:@"universal"];
        freeApp = [[properties objectForKey:@"freeApp"] boolValue];
        installed = (canReceive && [[UIApplication sharedApplication] canOpenURL:scheme]);
        appDescription = [[properties objectForKey:@"description"] copy];
        // select appropriate app icon for this device
        BOOL isRetina = [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f;
        NSString* thumbnailKey = isRetina ? @"thumbnail2xURL" : @"thumbnailURL";
        NSString* thumbnailURLStr = [properties objectForKey:thumbnailKey];
        if (thumbnailURLStr != nil) thumbnailURL = [[NSURL alloc] initWithString:thumbnailURLStr];            
    }
    return self;
}

- (void) dealloc
{
    [name release];
	[scheme release];
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

