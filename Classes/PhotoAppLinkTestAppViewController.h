//
//  PhotoAppLinkTestAppViewController.h
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoAppLinkTestAppViewController : UIViewController {
    IBOutlet UIButton* returnToPreviousAppButton;
    IBOutlet UIButton* sendToAppsButton;
    IBOutlet UIImageView* imageView;
    IBOutlet UILabel* callingAppLabel;
    
    UIImage* image;
}

@property (nonatomic, retain) UIButton *returnToPreviousAppButton;
@property (nonatomic, retain) UILabel *callingAppLabel;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) UIImageView *imageView;

- (IBAction)showSendToAppTable;
- (IBAction)returnToPreviousApp;


@end






