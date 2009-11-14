//
//  PhotoToolchainTestAppAppDelegate.h
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoToolchainTestAppViewController;

@interface PhotoToolchainTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    PhotoToolchainTestAppViewController* rootViewController;
}

@property (nonatomic, retain) IBOutlet PhotoToolchainTestAppViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


