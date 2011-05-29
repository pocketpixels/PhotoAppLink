//
//  PhotoAppLinkMoreAppsViewController.m
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 11-05-22.
//  Copyright 2011 Pocket Pixels Inc. All rights reserved.
//

#import "PhotoAppLinkMoreAppsViewController.h"
#import "PhotoAppLinkManager.h"  
#import "PhotoAppLinkMoreAppsTableCellView.h"

static const int ROWHEIGHT = 86;

@implementation PhotoAppLinkMoreAppsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        PhotoAppLinkManager* palManager = [PhotoAppLinkManager sharedPhotoAppLinkManager];
        // TODO filter out apps for the wrong platform
        NSString* deviceType = [[UIDevice currentDevice] model];
        BOOL isIPad = [deviceType hasPrefix:@"iPad"];
        NSPredicate* appsToShowPredicate;
        // Only show apps that are not yet installed (as far as we can tell) and that are supported on the user's device
        if (isIPad) {
            appsToShowPredicate = [NSPredicate predicateWithFormat:@"installed=FALSE AND NOT platform BEGINSWITH[cd] 'iPhone'"];
        }
        else {
            appsToShowPredicate = [NSPredicate predicateWithFormat:@"installed=FALSE AND NOT platform BEGINSWITH[cd] 'iPad'"];            
        }
        additionalApps =  [palManager.supportedApps filteredArrayUsingPredicate:appsToShowPredicate];
        [additionalApps retain];
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, -20, 0);
    self.navigationItem.title = NSLocalizedString(@"Compatible Apps", @"PhotoAppLink");

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    PhotoAppLinkMoreAppsTableCellView* appInfoView;
    UIButton* storeButton;
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PAL_tablecell_background.png"]];
        CGRect cellFrame = CGRectMake(0.0, 0.0, tableView.frame.size.width, ROWHEIGHT);
        appInfoView= [[PhotoAppLinkMoreAppsTableCellView alloc] initWithFrame:cellFrame];
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
        appInfoView = (PhotoAppLinkMoreAppsTableCellView*) [cell.contentView viewWithTag:APPINFOVIEW_TAG];
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
    // TODO dismiss modal view controller?
    NSURL* appStoreURL = [appInfo appStoreLink];
    if (appStoreURL != nil) {
        [[UIApplication sharedApplication] openURL:appStoreURL];        
    }
}

@end
