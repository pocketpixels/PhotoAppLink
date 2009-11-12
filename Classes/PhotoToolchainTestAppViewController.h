//
//  PhotoToolchainTestAppViewController.h
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoToolchainTestAppViewController : UIViewController {
    IBOutlet UIButton* sendToAppsButton;
    IBOutlet UIImageView* imageView;
    
    UIImage* image;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;

- (IBAction) showSendToAppTable:(id)sender;


@end




