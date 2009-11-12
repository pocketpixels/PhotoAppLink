//
//  TargetAppsTableViewController.h
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-10.
//  Copyright 2009 Pocket Pixels Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TargetAppsTableViewController : UITableViewController {
    NSArray* targetAppNames;
    UIImage* currentImage;
}

@property (nonatomic, retain) UIImage *currentImage;
@property (nonatomic, retain) NSArray *targetAppNames;

@end


