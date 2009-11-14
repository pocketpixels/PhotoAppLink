//
//  PhotoAppChainTestAppAppDelegate.h
//  PhotoAppChainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoAppChainTestAppViewController;

@interface PhotoAppChainTestAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
    PhotoAppChainTestAppViewController* rootViewController;
}

@property (nonatomic, retain) IBOutlet PhotoAppChainTestAppViewController *rootViewController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end


