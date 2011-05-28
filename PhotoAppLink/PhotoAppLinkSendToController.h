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

@protocol PhotoAppLinkSendToControllerDelegate <NSObject>

@optional
- (void)photoAppLinkImage:(UIImage*)image sendToItemWithIdentifier:(int)identifier;
- (UIImage*)photoAppLinkImage;

@end

@interface PhotoAppLinkSendToController : UIViewController <UIScrollViewDelegate> {
    
    id<PhotoAppLinkSendToControllerDelegate> _delegate;
    UIImage *_image;
    
    UIScrollView *_iconsScrollView;
    UIPageControl *_iconsPageControl;
    UIButton *_moreAppsButton;
    UINavigationBar *_myNavigationBar;
    UINavigationItem *_myNavigationItem;
    
    NSMutableArray *_sharingActions;
}

@property (nonatomic, assign) id<PhotoAppLinkSendToControllerDelegate> delegate;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, retain) IBOutlet UIScrollView *iconsScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *iconsPageControl;
@property (nonatomic, retain) IBOutlet UIButton *moreAppsButton;
@property (nonatomic, retain) IBOutlet UINavigationBar *myNavigationBar;
@property (nonatomic, retain) IBOutlet UINavigationItem *myNavigationItem;

- (void)addSharingActionWithTitle:(NSString*)title icon:(UIImage*)icon identifier:(int)identifier;
- (IBAction)dismissView:(id)sender;
- (IBAction)pageChanged:(id)sender;
- (IBAction)moreApps:(id)sender;

@end
