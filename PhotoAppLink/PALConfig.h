//
//  PALConfig.h
//


// Substitute this for testing with your own edited server side plist URL
// (Make sure to set up your XCode project so that DEBUG is defined in debug builds, 
//  otherwise the production plist file will be used)
#define DEBUG_PLIST_URL     @"http://www.photoapplink.com/photoapplink_debug.plist"


// If you are not using app icons to display the list of supported apps in your UI 
// (for example because you only use the action sheet displaying the app names)
// you can set this to NO to disable downloading of these app icons
#define USING_APP_ICONS     YES


// Substitute your own Linkshare Site ID here if you like.
// This Linkshare ID is used to create affiliate links to 
// supported apps on the App Store
#define LINKSHARE_SITE_ID   @"voTw02jXldU"


// The image to use for apps with missing icons
// The file has to be included in the app bundle
#define GENERIC_APP_ICON    @"PAL_unknown_app_icon.png"


// The placeholder image to show while the image
// is loading.  It will be replaced with the actual
// app icon or the generic icon.
#define PLACEHOLDER_APP_ICON @"PAL_default_app_icon.png"
