//
//  PALConfig.m
//

#import "PALConfig.h"

static PALConfig *sharedInstance = nil;

////////LegacyPALConfigDelegate
@interface LegacyPALConfigDelegate : NSObject <PALConfigDelegate>  {
	NSDictionary *configuration;
}
@end

@implementation LegacyPALConfigDelegate
- (id)init
{
    if ((self = [super init])) {
		configuration = [[NSDictionary alloc] initWithObjectsAndKeys:
						 DEBUG_PLIST_URL, @"debugPListURL", 
						 USING_APP_ICONS, @"usingAppIcons", 
						 LINKSHARE_SITE_ID, @"linkShareSiteID", 
						 GENERIC_APP_ICON, @"genericAppIcon", 
						 nil];
	}
	
	//NSLog(@"Legacy configuration: %@", configuration);
	
    return self;	
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	return [super respondsToSelector:aSelector] || [configuration objectForKey:NSStringFromSelector(aSelector)] != nil;
}

- (id) performSelector:(SEL)aSelector
{
	id configValue = [configuration objectForKey:NSStringFromSelector(aSelector)];
	if(configValue == nil) {
		return [super performSelector:aSelector];
	} else {
		return configValue;
	}
}
@end
////////LegacyPALConfigDelegate


////////PALConfig
@interface PALConfig()
@property (nonatomic, retain) id <PALConfigDelegate> delegate;
@end


@implementation PALConfig

@synthesize delegate;

#pragma mark -
#pragma mark Instance methods

- (id)configurationValue:(NSString*)selector
{
//	NSLog(@"Looking for a configuration value for %@.", selector);
	
	SEL sel = NSSelectorFromString(selector);
	if ([delegate respondsToSelector:sel]) {
		id value = [delegate performSelector:sel];
		if (value) {
//			NSLog(@"Found configuration value for %@: %@", selector, value);
			return value;
		}
	}
	
//	NSLog(@"Didn't find a configuration value for %@.", selector);
	return nil;
}

#pragma mark -
#pragma mark Singleton methods

// Singleton template based on http://stackoverflow.com/questions/145154

+ (PALConfig*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[PALConfig alloc] initWithDelegate:[[LegacyPALConfigDelegate alloc] init]];
    }
    return sharedInstance;
}

+ (PALConfig*)sharedInstanceWithDelegate:(id <PALConfigDelegate>)delegate
{
    @synchronized(self)
    {
		if (sharedInstance != nil) {
			[NSException raise:@"IllegalStateException" format:@"PALConfig has already been configured with a delegate."];
		}
		sharedInstance = [[PALConfig alloc] initWithDelegate:delegate];
    }
    return sharedInstance;
}


+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)initWithDelegate:(id <PALConfigDelegate>)delegateIn
{
    if ((self = [super init])) {
		self.delegate = delegateIn;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}
////////PALConfig

@end
