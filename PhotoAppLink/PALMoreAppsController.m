//
//  PALMoreAppsController.m
//  Created by Hendrik Kueck on 11-05-22.
//

#import "PALMoreAppsController.h"
#import "PALManager.h"  
#import "PALMoreAppsTableCellView.h"
#import "PALAppInfo.h"

static const int ROWHEIGHT = 86;
static const int INSET_HEIGHT = 20;
static const int MIN_POPOVER_HEIGHT = 400;

@interface PALMoreAppsController (PrivateStuff)

- (void)dismissWithLeavingApp:(BOOL)leavingApp;
- (BOOL)isPresentedModally;

@end


@implementation PALMoreAppsController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        additionalApps = [[[PALManager sharedPALManager] moreApps] retain];
    }
    return self;
}

- (id)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (void)dealloc
{
    [additionalApps release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSAssert(self.navigationController != nil, @"PALMoreAppsController must be presented in a UINavigationController");

    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = ROWHEIGHT;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    
    UIImage* shadowImage = [UIImage imageNamed:@"PAL_tableview_shadow.png"];
    UIImageView* bottomShadowView = [[UIImageView alloc] initWithImage:shadowImage];
    UIImageView* topShadowView = [[UIImageView alloc] initWithImage:shadowImage];
    [topShadowView setTransform:CGAffineTransformMakeScale(1.0, -1.0)];
    self.tableView.tableFooterView = bottomShadowView;
    self.tableView.tableHeaderView = topShadowView;
    [bottomShadowView release];
    [topShadowView release];
    self.tableView.contentInset = UIEdgeInsetsMake(-INSET_HEIGHT, 0, -INSET_HEIGHT, 0);
    self.navigationItem.title = NSLocalizedString(@"Compatible Apps", @"PhotoAppLink");

    BOOL weAreTheRootController = ([self.navigationController.viewControllers objectAtIndex:0] == self);
    if ([self isPresentedModally] && weAreTheRootController) {
        UIBarButtonItem* cancelButton = 
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"PhotoAppLink")
                                         style:UIBarButtonItemStyleBordered 
                                        target:self action:@selector(cancel)];
        [[self navigationItem] setLeftBarButtonItem:cancelButton];
        [cancelButton release];        
    }
}

// Called by the notification center if the app becomes active and this view is still visible
// This is necessary to reload the list of compatible apps as it can change when the app
// becomes active again (user might buy another compatible app, for example)
- (void)applicationDidBecomeActive
{
    [additionalApps release];
    additionalApps = [[[PALManager sharedPALManager] moreApps] retain];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([self respondsToSelector:@selector(setContentSizeForViewInPopover:)]) {
        CGSize measuredSize = [self.tableView sizeThatFits:CGSizeMake(320.0, 850.0)];
        float popoverWidth = 320;
        float popoverHeight = MAX(MIN_POPOVER_HEIGHT, measuredSize.height - 2 * INSET_HEIGHT);
        self.contentSizeForViewInPopover = CGSizeMake(popoverWidth, popoverHeight);        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated 
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (BOOL)isPresentedModally
{
#ifdef __IPHONE_5_0
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        return ([self presentingViewController] != nil);
    } else {
        return (self.navigationController.parentViewController.modalViewController == self.navigationController);
    }
#else
    return (self.navigationController.parentViewController.modalViewController == self.navigationController);
#endif
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [additionalApps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PALAppInfoCell";
    static const int APPINFOVIEW_TAG = 1042;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    PALMoreAppsTableCellView* appInfoView;
    UIButton* storeButton;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PAL_tablecell_background.png"]] autorelease];
        CGRect cellFrame = CGRectMake(0.0, 0.0, tableView.frame.size.width, ROWHEIGHT);
        appInfoView= [[PALMoreAppsTableCellView alloc] initWithFrame:cellFrame];
        appInfoView.tag = APPINFOVIEW_TAG;
        [cell.contentView addSubview:appInfoView];
        [appInfoView release];
        // add button to go to App Store
        UIImage* buttonBG = [UIImage imageNamed:@"PAL_button_background.png"];
        UIImage* stretchableButtonBG = [buttonBG stretchableImageWithLeftCapWidth:5 topCapHeight:12];
        // TODO add assert
        storeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [storeButton setBackgroundImage:stretchableButtonBG forState:UIControlStateNormal];
        [storeButton addTarget:self action:@selector(storeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [storeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [storeButton.titleLabel setShadowColor:[UIColor blackColor]];
        [storeButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];        
        storeButton.frame = CGRectMake(0, 0, 50, 25);
        [cell setAccessoryView:storeButton];
    }
    else {
        appInfoView = (PALMoreAppsTableCellView*) [cell.contentView viewWithTag:APPINFOVIEW_TAG];
        appInfoView.frame = CGRectMake(0, 0, tableView.frame.size.width, ROWHEIGHT);
        storeButton = (UIButton*) cell.accessoryView;
    }

    PALAppInfo* appInfo = [additionalApps objectAtIndex:indexPath.row];
    [appInfoView setAppInfo:appInfo];
    storeButton.tag = indexPath.row;
    NSString* storeButtonText;
    if (appInfo.freeApp) {
        storeButtonText = NSLocalizedString(@"FREE", "PhotoAppLink");
    }
    else {
        storeButtonText = NSLocalizedString(@"Store", "PhotoAppLink");        
    }
    [storeButton setTitle:storeButtonText forState:UIControlStateNormal];
    return cell;
}

- (void)storeButtonTapped:(id)sender
{
    UIButton* tappedButton = sender;
    PALAppInfo* appInfo = [additionalApps objectAtIndex:tappedButton.tag];
    NSURL* appStoreURL = [appInfo appStoreLink];
    if (appStoreURL != nil) {
        [self dismissWithLeavingApp:YES];
        [[UIApplication sharedApplication] performSelector:@selector(openURL:) withObject:appStoreURL afterDelay:0.0];
    }
}

- (void)dismissWithLeavingApp:(BOOL)leavingApp
{
    if ([delegate respondsToSelector:@selector(finishedWithMoreAppsController:leavingApp:)]) {
        [delegate finishedWithMoreAppsController:self leavingApp:leavingApp];
    }
    else {
        // default behavior
        BOOL useAnimation = !leavingApp;
        if ([self isPresentedModally]) {
            [self dismissModalViewControllerAnimated:useAnimation];            
        }
        else {
            [self.navigationController popViewControllerAnimated:useAnimation];
        }
    }
}

- (void)cancel
{
    [self dismissWithLeavingApp:NO];
}

@end
