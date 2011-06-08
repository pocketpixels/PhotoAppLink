//
//  PALMoreAppsController.m
//  Created by Hendrik Kueck on 11-05-22.
//

#import "PALMoreAppsController.h"
#import "PALManager.h"  
#import "PALMoreAppsTableCellView.h"
#import "PALAppInfo.h"

static const int ROWHEIGHT = 86;

@interface PALMoreAppsController (PrivateStuff)

- (void)dismissWithLeavingApp:(BOOL)leavingApp;

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
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    self.navigationItem.title = NSLocalizedString(@"Compatible Apps", @"PhotoAppLink");

    BOOL isPresentedModally = (self.navigationController.parentViewController.modalViewController == self.navigationController);
    BOOL weAreTheRootController = ([self.navigationController.viewControllers objectAtIndex:0] == self);
    if (isPresentedModally && weAreTheRootController) {
        UIBarButtonItem* cancelButton = 
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"PhotoAppLink")
                                         style:UIBarButtonItemStyleBordered 
                                        target:self action:@selector(cancel)];
        [[self navigationItem] setLeftBarButtonItem:cancelButton];
        [cancelButton release];        
    }
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
        
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PAL_tablecell_background.png"]];
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
        BOOL isPresentedModally = (self.navigationController.parentViewController.modalViewController == self.navigationController);
        BOOL useAnimation = !leavingApp;
        if (isPresentedModally) {
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
