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

@interface PhotoAppLinkTestAppViewController()
@property (nonatomic, retain) UIButton *sendToAppsButton;
@property (nonatomic, retain) UIImageView *imageView;
@end

@implementation PhotoAppLinkTestAppViewController

@dynamic image;
@synthesize imageView;
@synthesize sendToAppsButton;

- (void)dealloc
{
	[sendToAppsButton release];
    [imageView release];

	[super dealloc];
}

- (IBAction)showSendToAppTable
{
    [[[PhotoAppLinkManager sharedPhotoAppLinkManager] actionSheetToSendImage:self.image] showInView:self.view];
}

- (void)setImage:(UIImage*)newImage
{
    self.imageView.image = newImage;
    if (newImage) {
        float imageWidth = newImage.size.width;
        float imageHeight = newImage.size.height;
        float maxDim = MAX(imageWidth, imageHeight);
        float scaleFactor = MIN(280.0 / maxDim, 1.0);
        self.imageView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);            
    }
}

- (UIImage*) image
{
    return self.imageView.image;
}

@end





