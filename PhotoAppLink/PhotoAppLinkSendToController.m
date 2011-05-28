//
//  PhotoAppLinkSendToController.m
//  PhotoAppLinkTestApp
//
//  Created by Gustavo Ambrozio on 26/5/11.
//

#import "PhotoAppLinkSendToController.h"
#import "PhotoAppLinkManager.h"
#import <QuartzCore/QuartzCore.h>

#define BUTTONS_WIDTH   57.0f
#define BUTTONS_HEIGHT  77.0f

#define BUTTONS_MIN_WIDTH   80.0f
#define BUTTONS_MIN_HEIGHT  90.0f



@interface PhotoAppLinkSendToController (PrivateStuff)

- (void)addButtonWithTitle:(NSString*)title icon:(UIImage*)icon inPosition:(int)position;
- (void)fixIconsLayoutAnimated:(BOOL)animated;
- (void)buttonClicked:(id)sender;

@end

@implementation PhotoAppLinkSendToController

@synthesize delegate = _delegate;
@synthesize image = _image;

@synthesize iconsScrollView = _iconsScrollView;
@synthesize iconsPageControl = _iconsPageControl;
@synthesize moreAppsButton = _moreAppsButton;
@synthesize topToolbar = _topToolbar;
@synthesize titleLabel = _titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_image release];
    [_sharingActions release];
    [_iconsScrollView release];
    [_iconsPageControl release];
    [_moreAppsButton release];
    [_topToolbar release];
    [_titleLabel release];
    [super dealloc];
}

- (NSString*)title {
    return _titleLabel.text;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Customization of the button to make it nicer.
    _moreAppsButton.layer.cornerRadius = 6.0f;
    _moreAppsButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _moreAppsButton.layer.borderWidth = 1.0f;
    _moreAppsButton.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    _moreAppsButton.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
    _moreAppsButton.layer.masksToBounds = YES;
    
    // Adding a gradient background
    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.bounds = _moreAppsButton.bounds;
    gradientLayer.position = CGPointMake(gradientLayer.bounds.size.width/2, gradientLayer.bounds.size.height/2);
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:98.0f/255.0f green:116.0f/255.0f blue:154.0f/255.0f alpha:1.0f] CGColor], 
                            (id)[[UIColor colorWithRed:52.0f/255.0f green: 90.0f/255.0f blue:154.0f/255.0f alpha:1.0f] CGColor], nil];
    [_moreAppsButton.layer insertSublayer:gradientLayer atIndex:0];
    [gradientLayer release];
    
    // My list of icons go here.
    // I'll customize this a bit.
    _iconsScrollView.layer.cornerRadius = 6.0f;
    _iconsScrollView.layer.borderColor = [[UIColor darkGrayColor] CGColor];

    if (self.navigationController)
    {
        // If it's presented as part of a navigation controller
        // I'll hide my toolbar and title
        _titleLabel.hidden = YES;
        _topToolbar.hidden = YES;
        
        // I have to extend the size of my icons view because the
        // navigation bar shrunk it...
        _iconsScrollView.frame = CGRectMake(_iconsScrollView.frame.origin.x,
                                            _iconsScrollView.frame.origin.y - _topToolbar.frame.size.height,
                                            _iconsScrollView.frame.size.width, 
                                            _iconsScrollView.frame.size.height + _topToolbar.frame.size.height);
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    int pos = 0;
    if (_sharingActions) 
    {
        for (NSArray *sharingAction in _sharingActions)
        {
            [self addButtonWithTitle:[sharingAction objectAtIndex:0]
                                icon:[sharingAction objectAtIndex:1]
                          inPosition:pos++];
        }
    }
    
    NSArray *sharers = [[PhotoAppLinkManager sharedPhotoAppLinkManager] destinationApps];
    for (PALAppInfo *info in sharers)
    {
        [self addButtonWithTitle:info.appName
                            icon:info.thumbnail
                      inPosition:pos++];
    }
    
    _iconsPageControl.currentPage = 0;
    [self fixIconsLayoutAnimated:NO];
}

- (void)viewDidUnload
{
    [self setIconsScrollView:nil];
    [self setIconsPageControl:nil];
    [self setMoreAppsButton:nil];
    [self setTopToolbar:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self fixIconsLayoutAnimated:YES];
}

- (void)addSharingActionWithTitle:(NSString*)title icon:(UIImage*)icon identifier:(int)identifier
{
    if (_sharingActions == nil)
        _sharingActions = [[NSMutableArray alloc] init];
    
    [_sharingActions addObject:[NSArray arrayWithObjects:title, icon, [NSNumber numberWithInt:identifier], nil]];
}

- (void)addButtonWithTitle:(NSString*)title icon:(UIImage*)icon inPosition:(int)position 
{
    UIView *encapsulator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, BUTTONS_WIDTH, BUTTONS_HEIGHT)];
    encapsulator.tag = position + 1;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = position + 1;
    btn.frame = CGRectMake(0.0f, 0.0f, BUTTONS_WIDTH, BUTTONS_WIDTH);
    btn.showsTouchWhenHighlighted = YES;
    [btn setImage:icon forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [encapsulator addSubview:btn];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, BUTTONS_WIDTH, BUTTONS_WIDTH, 20.0f)];
    lbl.text = title;
    lbl.font = [UIFont systemFontOfSize:12.0f];
    lbl.adjustsFontSizeToFitWidth = YES;
    lbl.textAlignment = UITextAlignmentCenter;
    lbl.backgroundColor = [UIColor clearColor];
    lbl.shadowColor = [UIColor lightTextColor];
    lbl.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [encapsulator addSubview:lbl];
    [lbl release];
    
    [_iconsScrollView addSubview:encapsulator];
    [encapsulator release];
}

- (void)fixIconsLayoutAnimated:(BOOL)animated
{
    NSArray *subviews = [_iconsScrollView subviews];
    if ([subviews count] > 0)
    {
        if (animated)
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.1f];
        }
        
        CGFloat w = _iconsScrollView.bounds.size.width;
        CGFloat h = _iconsScrollView.bounds.size.height;
        
        int iconsX = (int)floor(w / BUTTONS_MIN_WIDTH);
        int iconsY = (int)floor(h / BUTTONS_MIN_HEIGHT);
        
        CGFloat dx = floor(w / iconsX);
        CGFloat dy = floor(h / iconsY);
        CGFloat x0 = floor((dx - BUTTONS_WIDTH) / 2.0f);
        CGFloat y0 = floor((dy - BUTTONS_HEIGHT) / 2.0f);
        
        int posX = 0;
        int posY = 0;
        int page = 0;
        for (UIView *view in subviews)
        {
            view.frame = CGRectMake(x0 + dx * posX + page * w, 
                                    y0 + dy * posY, 
                                    BUTTONS_WIDTH, 
                                    BUTTONS_HEIGHT);
            
            if (++posX == iconsX)
            {
                posX = 0;
                if (++posY == iconsY)
                {
                    posY = 0;
                    page++;
                }
            }
        }
        
        if (posX != 0 || posY != 0)
            page++;
        
        _iconsPageControl.hidden = (page <= 1);
        _iconsScrollView.contentSize = CGSizeMake(page * w, h);
        
        _iconsPageControl.numberOfPages = page;
        if (_iconsPageControl.currentPage >= page)
            _iconsPageControl.currentPage = page - 1;
        
        [_iconsScrollView scrollRectToVisible:CGRectMake(_iconsPageControl.currentPage * w, 0.0f,
                                                         w, h) 
                                     animated:NO];
        
        if (animated)
        {
            [UIView commitAnimations];
        }
    }
}

- (void)buttonClicked:(id)sender
{
    int position = [sender tag] - 1;
    if (_sharingActions && position < [_sharingActions count])
    {
        NSArray *sharingAction = [_sharingActions objectAtIndex:position];
        [_delegate photoAppLinkImageSendToItemWithIdentifier:[[sharingAction objectAtIndex:2] intValue]];
    }
    else
    {
        if (_sharingActions)
            position -= [_sharingActions count];
        
        NSArray *sharers = [[PhotoAppLinkManager sharedPhotoAppLinkManager] destinationApps];
        PALAppInfo *info = [sharers objectAtIndex:position];
        UIImage *imageToShare = self.image;
        if (imageToShare == nil && _delegate && [_delegate respondsToSelector:@selector(photoAppLinkImage)])
            imageToShare = [_delegate photoAppLinkImage];
        if (imageToShare)
            [[PhotoAppLinkManager sharedPhotoAppLinkManager] invokeApplication:info.appName withImage:imageToShare];
        else
            NSLog(@"This should not happen! You have to either set this object's image or set a delegate and implement photoAppLinkImage");
    }
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)dismissView:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pageChanged:(id)sender
{
    [_iconsScrollView scrollRectToVisible:CGRectMake(_iconsPageControl.currentPage * _iconsScrollView.frame.size.width, 0.0f,
                                                     _iconsScrollView.frame.size.width, _iconsScrollView.frame.size.height) 
                                 animated:YES];
}

#pragma mark -
#pragma UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _iconsPageControl.currentPage = _iconsScrollView.contentOffset.x / _iconsScrollView.frame.size.width;
}

@end
