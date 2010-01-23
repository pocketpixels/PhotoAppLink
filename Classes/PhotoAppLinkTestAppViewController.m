//    Copyright (c) 2009 Hendrik Kueck
//
//    Permission is hereby granted, free of charge, to any person obtaining
//    a copy of this software and associated documentation files (the
//    "Software"), to deal in the Software without restriction, including
//    without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to
//    permit persons to whom the Software is furnished to do so, subject to
//    the following conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//    LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//    WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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





