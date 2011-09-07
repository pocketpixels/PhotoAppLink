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

#import "TestAppRootViewController.h"
#import "PALSendToController.h"
#import "PALManager.h"
#import "PALMoreAppsController.h"

@interface TestAppRootViewController()
@property (nonatomic, retain) UIImageView *imageView;
@end

@implementation TestAppRootViewController

@dynamic image;
@synthesize imageView;

- (void)dealloc
{
    [imageView release];
	[super dealloc];
}

- (IBAction)showActionSheet
{
    // Simple UIActionSheet method
    UIActionSheet *actionSheet = [[PALManager sharedPALManager] actionSheetToSendImage:self.image];
    if (actionSheet)
    {
        [actionSheet showInView:self.view];
    }
    else
    {
        UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                          message:@"You don't have any PhotoAppLink compatible apps installed in your device"
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil];
        [newView show];
        [newView release];
    }
}

- (IBAction)showSendToAppController
{
    // PhotoAppLinkSendToController method
    PALSendToController *newView = [[PALSendToController alloc] init];

    // These are custom buttons for your own sharing options, such as send to fb, twitter, etc...
    [newView addSharingActionWithTitle:@"Facebook" icon:[UIImage imageNamed:@"facebook-icon.png"] identifier:1];
    [newView addSharingActionWithTitle:@"Twitter" icon:[UIImage imageNamed:@"twitter-icon.png"] identifier:2];
    
    // The image you want to share. This can also be provided by a delegate method
    newView.image = self.image;
    
    // Gotta set the delegate because of the custom sharing items. Otherwise not needed.
    newView.delegate = self;

    // Present it however you want...
    [self.navigationController pushViewController:newView animated:YES];
//    [self presentModalViewController:newView animated:YES];
    
    [newView release];
}

- (IBAction)showMoreAppsTable
{
    PALMoreAppsController* moreAppsVC = [[PALMoreAppsController alloc] init];
    [self.navigationController pushViewController:moreAppsVC animated:YES];
    [moreAppsVC release];
}

- (IBAction)modallyPresentSendToController
{
    PALSendToController *newView = [[PALSendToController alloc] init];
    newView.image = self.image;

    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:newView];
    [newView release];
    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (IBAction)modallyPresentMoreAppsController
{
    PALMoreAppsController* moreAppsVC = [[PALMoreAppsController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:moreAppsVC];
    [moreAppsVC release];
    [self presentModalViewController:nav animated:YES];
    [nav release];
}

- (IBAction)pictureFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:imagePickerController animated:YES];
        [imagePickerController release];
    }
    else
    {
        UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                          message:@"Camera not alaivable"
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil];
        [newView show];
        [newView release];
    }
}

- (IBAction)pictureFromRoll
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePickerController animated:YES];
        [imagePickerController release];
    }
    else
    {
        UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                          message:@"Photo Library not alaivable"
                                                         delegate:nil 
                                                cancelButtonTitle:@"OK" 
                                                otherButtonTitles:nil];
        [newView show];
        [newView release];
    }
}

#pragma mark -
#pragma PhotoAppLinkSendToControllerDelegate

// Delegate method that gets called when a custom sharing item is pressed by the user.
- (void)photoAppLinkImage:(UIImage*)image sendToItemWithIdentifier:(int)identifier
{
    UIAlertView *newView = [[UIAlertView alloc] initWithTitle:nil 
                                                      message:[NSString stringWithFormat:@"Triggered %@ sharing option", identifier==1?@"Facebook":@"Twitter"]
                                                     delegate:nil 
                                            cancelButtonTitle:@"OK" 
                                            otherButtonTitles:nil];
    [newView show];
    [newView release];
}

- (void)setImage:(UIImage*)newImage
{
    self.imageView.image = newImage;
}

- (UIImage*) image
{
    return self.imageView.image;
}

#pragma mark -
#pragma UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self setImage:image];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

@end





