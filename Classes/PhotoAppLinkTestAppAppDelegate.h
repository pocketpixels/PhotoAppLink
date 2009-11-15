//
//  PhotoAppLinkTestAppAppDelegate.h
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAppLinkTestAppViewController;

@interface PhotoAppLinkTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    PhotoAppLinkTestAppViewController* rootViewController;
}

@property (nonatomic, retain) IBOutlet PhotoAppLinkTestAppViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


