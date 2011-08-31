//
//  PALConfig.h
//

// You can edit these constants directly, or provide a delegate that provides the values

// Substitute this for testing with your own edited server side plist URL
// (Make sure to set up your XCode project so that DEBUG is defined in debug builds, 
//  otherwise the production plist file will be used)
#define DEBUG_PLIST_URL     @"http://www.photoapplink.com/photoapplink_debug.plist"


// If you are not using app icons to display the list of supported apps in your UI 
// (for example because you only use the action sheet displaying the app names)
// you can set this to NO to disable downloading of these app icons
#define USING_APP_ICONS     @"YES"	// see NSString's boolValue, no is @"0"


// Substitute your own Linkshare Site ID here if you like.
// This Linkshare ID is used to create affiliate links to 
// supported apps on the App Store
#define LINKSHARE_SITE_ID   @"voTw02jXldU"


// The image to use for apps with missing icons
// The file has to be included in the app bundle
#define GENERIC_APP_ICON    @"PAL_unknown_app_icon.png"



@protocol PALConfigDelegate;

@interface PALConfig : NSObject {
	id <PALConfigDelegate> delegate;
}

@property (nonatomic,readonly, retain) id <PALConfigDelegate> delegate;

+ (PALConfig*)sharedInstance;
+ (PALConfig*)sharedInstanceWithDelegate:(id <PALConfigDelegate>)delegate;

- (id)initWithDelegate:(id <PALConfigDelegate>)delegate;
- (id)configurationValue:(NSString*)selector;

#define PALCONFIG(_CONFIG_KEY) [[PALConfig sharedInstance] configurationValue:@#_CONFIG_KEY]

@end


@protocol PALConfigDelegate <NSObject>
@optional

- (NSString*)debugPListURL;
- (NSString*)usingAppIcons;
- (NSString*)linkShareSiteID;
- (NSString*)genericAppIcon;
@end
