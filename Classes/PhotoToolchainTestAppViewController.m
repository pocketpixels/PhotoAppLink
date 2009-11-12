//
//  PhotoToolchainTestAppViewController.m
//  PhotoToolchainTestApp
//
//  Created by Hendrik Kueck on 09-11-09.
//  Copyright Pocket Pixels Inc 2009. All rights reserved.
//

#import "PhotoToolchainTestAppViewController.h"
#import "TargetAppsTableViewController.h"
#import "PhotoToolchainManager.h"

@implementation PhotoToolchainTestAppViewController

@synthesize image;
@synthesize imageView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction) showSendToAppTable:(id)sender
{
    PhotoToolchainManager* toolchain = [PhotoToolchainManager sharedPhotoToolchainManager];
    TargetAppsTableViewController* targetAppTable = [[TargetAppsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    NSArray* supportedAppNames = [toolchain destinationAppNames];
    targetAppTable.targetAppNames = supportedAppNames;

    [self presentModalViewController:targetAppTable animated:YES];
    [targetAppTable release];
}

-(void) setImage:(UIImage*) newImage
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

@end



