//    Copyright (c) 2011 Gustavo Ambrozio
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
//
//   Please, visit http://blog.codecropper.com/photoapplink-library-tutorial/ on details
//   about how to use this view controller
//

#import <UIKit/UIKit.h>

@protocol PALSendToControllerDelegate <NSObject>

@optional
// Called if you add custm sharers
- (void)photoAppLinkImage:(UIImage*)image sendToItemWithIdentifier:(int)identifier;

// If you want to defer providing an image you can use this delegate method
// Useful if you need processing to generate the image. In this case
// if the user cancels the action you didn't have to generate it.
- (UIImage*)photoAppLinkImage;

@end

@interface PALSendToController : UIViewController <UIScrollViewDelegate> {
    
    id<PALSendToControllerDelegate> _delegate;
    UIImage *_image;
    
    UIScrollView *_iconsScrollView;
    UIImageView *_scrollViewBackgroundView;
    UIPageControl *_iconsPageControl;
    UIButton *_moreAppsButton;
    UINavigationBar *_myNavigationBar;
    UINavigationItem *_myNavigationItem;
    
    NSMutableArray *_sharingActions;
}

// Provide a delegate if you have custom actions and/or if you want to defer image creation
@property (nonatomic, assign) id<PALSendToControllerDelegate> delegate;

// The image to share. Can be provided later by a delegate.
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) IBOutlet UIScrollView *iconsScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *scrollViewBackgroundView;

@property (nonatomic, retain) IBOutlet UIPageControl *iconsPageControl;
@property (nonatomic, retain) IBOutlet UIButton *moreAppsButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *myNavigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *myNavigationItem;

// Called after initialization and before presenting to add custom sharers
// If you do this you must provide a delegate that implements photoAppLinkImage:sendToItemWithIdentifier:
- (void)addSharingActionWithTitle:(NSString*)title icon:(UIImage*)icon identifier:(int)identifier;

// Actions
- (IBAction)dismissView:(id)sender;
- (IBAction)pageChanged:(id)sender;
- (IBAction)moreApps:(id)sender;

@end
