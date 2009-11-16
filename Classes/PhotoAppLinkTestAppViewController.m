//
//  PhotoAppLinkTestAppViewController.m
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import "PhotoAppLinkTestAppViewController.h"
#import "TargetAppsTableViewController.h"
#import "PhotoAppLinkManager.h"

@implementation PhotoAppLinkTestAppViewController

@synthesize callingAppLabel;
@synthesize image;
@synthesize imageView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)showSendToAppTable
{
    PhotoAppLinkManager* applink = [PhotoAppLinkManager sharedPhotoAppLinkManager];
    TargetAppsTableViewController* targetAppTable = [[TargetAppsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    NSArray* supportedAppNames = [applink destinationAppNames];
    targetAppTable.targetAppNames = supportedAppNames;
    targetAppTable.currentImage = self.image;
    [self.navigationController pushViewController:targetAppTable animated:YES];
    //    [self presentModalViewController:targetAppTable animated:YES];
    [targetAppTable release];
}

- (void)setImage:(UIImage*)newImage
{
    [image release];
    image = [newImage retain];
    self.imageView.image = image;

    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float maxDim = MAX(imageWidth, imageHeight);
    float scaleFactor = MIN(280.0 / maxDim, 1.0);
    self.imageView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);    
}

- (void)setPreviousAppBundleID:(NSString*)bundleID
{
    self.callingAppLabel.text = bundleID;
}

@end





