//
//  PhotoToolchainTestAppAppDelegate.m
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import "PhotoToolchainTestAppAppDelegate.h"
#import "PhotoToolchainTestAppViewController.h"
#import "PhotoToolchainManager.h"

@implementation PhotoToolchainTestAppAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    // Simply accessing the toolchain manager here triggers a background update of the list of supported apps
    // (if necessary). 
    PhotoToolchainManager* toolchain = [PhotoToolchainManager sharedPhotoToolchainManager];
    if (launchOptions == nil) {
        [self applicationDidFinishLaunching:application];
    }
    else {
        NSLog(@"Launched with options: %@", launchOptions);
        [window addSubview:viewController.view];
        [window makeKeyAndVisible];
        UIImage *image = [toolchain popPassedInImage];
        if (image) viewController.image = image;
        else viewController.image = [UIImage imageNamed:@"TestImage.png"];
    }
    return YES;
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    NSLog(@"Launched using applicationDidFinishLaunching:");
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [infoDict valueForKey:@"CFBundleName"];
    NSLog(@"App name seems to be %@", appName);
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
    // we did not receive an image
    viewController.image = [UIImage imageNamed:@"TestImage.png"];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
